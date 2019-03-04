class AlbumsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_album, only: [:show, :edit, :update, :destroy, :download]
  before_action :init
  before_action :set_ups_data, only: [:show]

  # GET /albums
  # GET /albums.json
  def index
    @page_title = "アルバム一覧"
    @sort = params[:sort].blank? ? 1 : params[:sort].to_i
    case @sort
    when 1
      @albums = Album.without_owner.id_desc
    when 2
      @albums = Album.without_owner.sort_by_uploaded
    else
      @albums = Album.without_owner.id_desc
    end

    @albums = Album.set_thumb(@albums)
    @albums = Kaminari.paginate_array(@albums).page(params[:page]).per(Rails.env.production? ? 20 : 5)

    @album_users = []
    Album.with_owner.each do |album|
      item_count = album.photos.count + album.movies.count
      @album_users << {name: album.owner.try(:dispname), item_count: item_count, album_id: album.id}
    end
  end

  def top
    @page_title = "アルバムトップ"
    @albums = Album.sort_by_uploaded[0..Album::INDEX_COLUMNS-1]
    @albums = Album.set_thumb(@albums)
    @movies = Movie.id_desc.limit(Album::INDEX_COLUMNS)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @albums }
    end

  end

  # GET /albums/1
  # GET /albums/1.json
  def show
    # 初期表示は「写真と動画」「アップロード順」
    default_sort_params = { sort_flg: 1, user_id: nil, media_filter: 1 }
    @album4sort = if params[:album].present?
                    Album.new(default_sort_params.merge(album_params))
                  else
                    Album.new(default_sort_params)
                  end

    # ソート順
    case @album4sort.sort_flg.to_i
    when 1
      photos = @album.photos.order("id DESC")
      movies = @album.movies.id_desc
    when 2
      photos = @album.photos.order("exif_at ASC")
      movies = @album.movies.id_desc
      # movies = @album.movies.order("exif_at ASC") # todo exif取れないよね？対応しなくていっかなー
    when 3
      photos = @album.photos.order("last_comment_at DESC")
      # todo できてない
      movies = @album.movies.id_desc
    when 4
      photos = @album.photos.order("nices.created_at DESC").order("last_comment_at DESC")
      movies = @album.movies.order("nices.created_at DESC")
    end

    # アップロード者でフィルタリング
    if @album4sort.user_id.present?
      photos = photos.where(user_id: @album4sort.user_id)
      movies = movies.where(user_id: @album4sort.user_id)
    end

    case @album4sort.media_filter.to_i
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
    @comments = @album.comments.select { |comment| comment.persisted? }

    # アップロード者リスト
    @uploader_list = @album.photos.includes(user: :user_ext).select('distinct user_id').map{|p| [p.user.id, p.user.dispname]}

    # 動画アップロード用
    @movie = @album.movies.build
    @movie_form_id = 'movie-form-new'

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
        @album.update_histories.create(user_id: current_user.id, action_type: UpdateHistory::ALBUM_CREATE)
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
    unless editable(current_user, @album.user)
      redirect_back fallback_location: root_path, alert: '削除権限がありません。'
      return
    end
    @album.destroy

    respond_to do |format|
      format.html { redirect_to albums_url, notice: 'アルバムを削除しました' }
      format.json { head :ok }
    end
  end

  def detail_index
    @albums = Album.sort_by_uploaded
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
    if params[:comment][:content].blank?
      @error_message = 'コメントを入力しないと投稿できません'
      render 'shared/error_alert.js'
      return
    end

    @comment = Comment.new(comment_params)
    @comment.user_id = current_user.id
    @comment.save
    @album = @comment.parent
    @comments = @album.comments

    UpdateHistory.for_creating_comment(@album, UpdateHistory::ALBUM_COMMENT, current_user.id)
  end

  def destroy_comment
    @comment = Comment.find(params[:id])
    @album = @comment.parent
    @comment.destroy
    UpdateHistory.for_destroying_comment(@album, UpdateHistory::ALBUM_COMMENT, current_user.id, @album.comments.last)
    @comments = @album.comments
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
    params.require(:album).permit(:title, :description, :thumb_id, :user_id, :sort_flg, :media_filter)
  end

  def comment_params
    params.require(:comment).permit(:user_id, :parent_id, :parent_type, :content)
  end
end
