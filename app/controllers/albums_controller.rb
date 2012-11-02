# -*- coding: utf-8 -*-
class AlbumsController < ApplicationController
  before_filter :login_after_uploadify # 多分、authenticate_userより先に実行する必要がある
  before_filter :authenticate_user!
  before_filter :set_title

  # GET /albums
  # GET /albums.json
  def index
    @title = "一覧"
    @sort = params[:sort].blank? ? 1 : params[:sort].to_i
    case @sort
    when 1
      @albums = Album.order("id DESC").page(params[:page])
    when 2
      @albums = Kaminari.paginate_array(Album.sort_upload).page(params[:page])
    else
      @albums = Album.order("id DESC").page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @albums }
    end
  end

  # GET /albums/1
  # GET /albums/1.json
  def show
    #更新情報一括閲覧用
    @ups_page, @ups_action_info = update_allview_helper(params[:ups_page], params[:ups_id])

    @sort = (params[:sort] =~ /1|2|3|4/) ? params[:sort].to_i : 1
    case @sort 
    when 1
      photos = @album.photos.order("id DESC")
    when 2
      photos = @album.photos.order("exif_at ASC")
    when 3
      photos = @album.photos.order("last_comment_at DESC")
    when 4
      photos = @album.photos.order("nices.created_at DESC").order("last_comment_at DESC")
    end

    # [暫定機能] アップロード者でフィルタリング
    if params[:user_id].present?
      photos = @album.photos.where(user_id: params[:user_id]).order("id DESC")
      @selected_uploader = User.find_by_id(params[:user_id])
    end

    @photos = photos.includes(:nices).page(params[:page])

    @comment = AlbumComment.new(:album_id => @album.id)

    @photo_all_num = @album.photos.size

    # アップロード者リスト(フィルタリングボタン用)
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
    @album = Album.new(params[:album])
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
      if @album.update_attributes(params[:album])
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
    @photo_count = Photo.count(:group => :album_id)
    @last_comment_at = Photo.maximum(:last_comment_at, :group => :album_id)
  end

  def download
    album = Album.find(params[:id])
    tmp = Tempfile.new('album')
    tmp_dir = tmp.path + '.dir'
    FileUtils.mkdir(tmp_dir)
    album.photos.each do |photo|
      if File.exist?(photo.image.path)
        FileUtils.cp photo.image.path, tmp_dir
      elsif File.exist?(photo.image.path(:large))
        FileUtils.cp photo.image.path(:large), tmp_dir
      end
    end

    ### tar.gz 形式の場合
    #`cd #{tmp_dir}; tar cvfz #{tarfile} *`
    #send_data File.open(tarfile).read, :filename => "#{album.title}.tar.gz", :type => 'application/x-gzip'

    zipfile = "#{tmp_dir}.zip"
    `cd #{tmp_dir}; zip #{zipfile} *`
    send_data File.open(zipfile).read, :filename => "#{album.title}.zip"

  ensure
    FileUtils.rm_rf(tmp_dir) if File.exist?(tmp_dir)
    tmp.close(true) if tmp
    FileUtils.rm(zipfile) if File.exist?(zipfile)
  end

  def set_title
    @album = Album.find(params[:id]) if params[:id].present?
    @title = @album.title if @album.present?
  end


private

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
