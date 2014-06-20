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
      @albums = Album.without_owner.order("id DESC")
    when 2
      @albums = Album.without_owner.sort_upload
    else
      @albums = Album.without_owner.order("id DESC")
    end

    Album.set_thumb_if_noset(@albums)
    @albums = Kaminari.paginate_array(@albums).page(params[:page])

    @album_users = []
    Album.with_owner.each do |album|
      item_count = album.photos.count + album.movies.count
      @album_users << {name: album.owner.try(:dispname), item_count: item_count, album_id: album.id}
    end
  end

  def top
    @page_title = "アルバムトップ"
    # @albums = Kaminari.paginate_array(Album.sort_upload).page(params[:page]).per(10)
    @albums = Album.sort_upload[0..9]
    Album.set_thumb_if_noset(@albums)
    @movies = Movie.order("id DESC").limit(10)

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

    uploader = nil
    @sort_flg = 2
    @media_filter = 1
    if params[:album].present?
      uploader = params[:album][:user_id]
      # 初期表示は「撮影日時順」
      @sort_flg = params[:album][:sort_flg] =~ /1|2|3|4/ ? params[:album][:sort_flg].to_i : 2
      # 写真か動画のフィルタリング
      @media_filter = params[:album][:media_filter].blank? ? 1 : params[:album][:media_filter].to_i
    end
    @album4sort = Album.new(sort_flg: @sort_flg, user_id: uploader, media_filter: @media_filter)

    # ソート順
    case @sort_flg
    when 1
      photos = @album.photos.order("id DESC")
      movies = @album.movies.order("id DESC")
    when 2
      photos = @album.photos.order("exif_at ASC")
      movies = @album.movies.order("id DESC")
      # movies = @album.movies.order("exif_at ASC") # todo exif取れないよね？対応しなくていっかなー
    when 3
      photos = @album.photos.order("last_comment_at DESC")
      # todo できてない
      movies = @album.movies.order("id DESC")
    when 4
      photos = @album.photos.order("nices.created_at DESC").order("last_comment_at DESC")
      movies = @album.movies.order("nices.created_at DESC")
    end

    # アップロード者でフィルタリング
    if uploader.present?
      photos = photos.where(user_id: uploader)
      movies = movies.where(user_id: uploader)
      @selected_uploader = User.find_by_id(uploader)
    end

    case @media_filter
    when 1
      @medias = movies.includes_all + photos.includes_all
      @media_name  = "写真と動画"
    when 2
      @medias = photos.includes_all
      @media_name  = "写真"
    when 3
      @medias = movies.includes_all
      @media_name  = "動画"
    end

    @medias = Kaminari.paginate_array(@medias).page(params[:page])

    @new_comment = @album.comments.build

    @medias_all_num = @album.photos.size + @album.movies.size

    # アップロード者リスト
    @uploader_list = @album.photos.includes(user: :user_ext).select('distinct user_id').map{|p| [p.user.id, p.user.dispname]}

    # AutoPager対応
    @autopagerable = true

    # 動画アップロード用
    @movie = @album.movies.build

    if params["focus_comment"].present?
      @tab_select_index = "eq(1)"
    else
      @tab_select_index = "first"
    end

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

  def create_comment
    @comment = Comment.new(comment_params)
    @comment.user_id = current_user.id
    @comment.save
    @album = @comment.parent

    UpdateHistory.create_or_update(current_user.id, UpdateHistory::ALBUM_COMMENT, @album)
  end

  def destroy_comment
    @comment = Comment.find(params[:id])
    @album = @comment.parent
    @comment.destroy
    @destroy_flg = true
    render 'create_comment.js'
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

  def comment_params
    params.require(:comment).permit(:user_id, :parent_id, :parent_type, :content)
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
