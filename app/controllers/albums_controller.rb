class AlbumsController < ApplicationController
  before_filter :login_after_uploadify # 多分、authenticate_userより先に実行する必要がある
  before_filter :authenticate_user!
  before_action :set_album, only: [:show, :edit, :update, :destroy, :download]
  before_action :init

  # GET /albums
  # GET /albums.json
  def index
    @page_title = "アルバム一覧"
    @sort = params[:sort].blank? ? 1 : params[:sort].to_i
    case @sort
    when 1
      @albums = Album.order("id DESC").page(params[:page])
    when 2
      @albums = Kaminari.paginate_array(Album.sort_upload).page(params[:page])
    else
      @albums = Album.order("id DESC").page(params[:page])
    end

    @album_users = []
    Album.where("owner_id is not NULL").each do |album|
      @album_users << {name: album.owner.try(:dispname), photo_count: album.photos.count, album_id: album.id}
    end
    p @album_users
  end

  def top
    @page_title = "アルバムトップ"
    @albums = Album.order("id DESC").page(params[:page])
    @movies = Movie.order("id DESC").limit(8)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @albums }
    end

  end

  def movies
    @page_title = "動画一覧"
    @movies = Movie.order("id DESC").page(params[:page]).per(16)
    render 'movies/index'
  end

  # GET /albums/1
  # GET /albums/1.json
  def show
    #更新情報一括閲覧用
    @ups_page, @ups_action_info = update_allview_helper(params[:ups_page], params[:ups_id])

    uploader = params[:album].present? ? params[:album][:user_id] : nil
    # 初期表示は「撮影日時順」
    @sort_flg = (params[:album].present? && params[:album][:sort_flg] =~ /1|2|3|4/) ? params[:album][:sort_flg].to_i : 2
    @album4sort = Album.new(sort_flg: @sort_flg, user_id: uploader)

    # ソート順
    case @sort_flg
    when 1
      photos = @album.photos.order("id DESC")
    when 2
      photos = @album.photos.order("exif_at ASC")
    when 3
      photos = @album.photos.order("last_comment_at DESC")
    when 4
      photos = @album.photos.order("nices.created_at DESC").order("last_comment_at DESC")
    end

    # アップロード者でフィルタリング
    if uploader.present?
      photos = photos.where(user_id: uploader)
      @selected_uploader = User.find_by_id(uploader)
    end

    @photos = photos.includes(:nices).page(params[:page])

    @comment = AlbumComment.new(:album_id => @album.id)

    @photo_all_num = @album.photos.size

    # アップロード者リスト
    @uploader_list = @album.photos.includes(user: :user_ext).select('distinct user_id').map{|p| [p.user.id, p.user.dispname]}

    # AutoPager対応
    @autopagerable = true

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @album }
    end
  end

  # GET /albums/new
  # GET /albums/new.json
  def new
    @album = Album.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @album }
    end
  end

  # GET /albums/1/edit
  def edit
    @page_title = "アルバムを編集する"
  end

  # POST /albums
  # POST /albums.json
  def create
    @album = Album.new(album_params)
    @album.user_id = current_user.id

    respond_to do |format|
      if @album.save
        @album.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::ALBUM_CREATE)
        format.html { redirect_to @album, notice: 'アルバムを作成しました。' }
        format.json { render json: @album, status: :created, location: @album }
      else
        format.html { render action: "new" }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /albums/1
  # PUT /albums/1.json
  def update
    respond_to do |format|
      if @album.update_attributes(album_params)
        format.html { redirect_to @album, notice: 'アルバム情報を更新しました。' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @album.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /albums/1
  # DELETE /albums/1.json
  def destroy
    @album.destroy

    respond_to do |format|
      format.html { redirect_to albums_url }
      format.json { head :ok }
    end
  end


  def title_index
    @albums = Album.sort_upload
    @photo_count = Photo.group(:album_id).count
    @last_comment_at = Photo.group(:album_id).maximum(:last_comment_at)
  end

  def download
    tmp = Tempfile.new('album')
    tmp_dir = tmp.path + '.dir'
    FileUtils.mkdir(tmp_dir)
    @album.photos.each do |photo|
      if File.exist?(photo.image.path)
        FileUtils.cp photo.image.path, tmp_dir
      elsif File.exist?(photo.image.path(:large))
        FileUtils.cp photo.image.path(:large), tmp_dir
      end
    end

    ### tar.gz 形式の場合
    #`cd #{tmp_dir}; tar cvfz #{tarfile} *`
    #send_data File.open(tarfile).read, :filename => "#{@album.title}.tar.gz", :type => 'application/x-gzip'

    zipfile = "#{tmp_dir}.zip"
    `cd #{tmp_dir}; zip #{zipfile} *`
    send_data File.open(zipfile).read, :filename => "#{@album.title}.zip"

  ensure
    FileUtils.rm_rf(tmp_dir) if File.exist?(tmp_dir)
    tmp.close(true) if tmp
    FileUtils.rm(zipfile) if File.exist?(zipfile)
  end



  private

  def init
    @page_content_type = "アルバム"
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_album
    @album = Album.find(params[:id])
    @page_content_title = @album.title if @album.present?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def album_params
    params.require(:album).permit(:title, :description, :thumb_id, :user_id, :sort_flg)
  end

  # user_idが入っていたら、Uploadifyでアップロードしてセッションが切れてしまった後に
  # リダイレクトされてきたものと判断してログインする
  # ※これやらないとログアウト状態なのでログイン画面に行ってしまう
  def login_after_uploadify
    if params[:user_id].present?
      user = User.find_by_id(params[:user_id])
      sign_in(user, :bypass => true)
    end
  end
end
