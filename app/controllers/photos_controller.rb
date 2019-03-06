class PhotosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_photo, only: [:show, :edit, :update, :destroy, :slideshow, :update_from_slideshow]
  before_action :set_ups_data, only: [:show]

  # GET /photos
  # GET /photos.json
  def index
    @photos = Photo.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @photos }
    end
  end

  # GET /photos/1
  # GET /photos/1.json
  #
  # 使用時の注意：これは通常のレイアウトを使用するため、colorboxで使う用ではない。colorboxを使用するなら、layoutをオフにしてapplication.jsを読みこまないslideshowメソッドを使用する
  # →colorboxにした場合にapplication.jsをバックとフロントでどちらも読み込んでしまうと、Ajaxで多重書き込みが起きてしまう
  #
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @photo }
    end
  end

  # GET /photos/new
  # GET /photos/new.json
  def new
    @photo = Photo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @photo }
    end
  end

  # GET /photos/1/edit
  def edit
  end

  # POST /photos
  # POST /photos.json
  def create
    if params[:photo_files].blank?
      render json: [ 'ファイルを選択してください' ], status: :unprocessable_entity
      return
    end

    album = Album.find(params['album_id'])
    # TODO: Transactionかけるとかエラーハンドリングしたい
    params[:photo_files].each do |file|
      photo = Photo.new(image: file, title: '[無題]', album_id: album.id, user_id: current_user.id, exif_at: Photo::set_exif_at(file.path))
      photo.save
    end

    # memo Ajaxでのpostはsaveのエラーが画面には表示されないので、自分で出力してあげる
    # あと、pメソッドでログに出力されないため、loggerを使用する
    # logger.debug @photo.errors.full_messages.inspect
    # logger.debug @photo.errors.full_messages.to_sentence

    UpdateHistory.create_or_update(album, UpdateHistory::ALBUMPHOTO_CREATE, current_user.id)
    render json: {}, status: :created
  end

  # PCからはcolorboxで使用する前提。スマホからは一つのページとして表示する
  def slideshow
    @from_top_flg = true if params[:top].present?
    #sakikazu PCからはJSをincludeしないようにレイアウトをオフにして、Ajaxの多重書き込みを防ぐ(※スマホからは見づらいのでcolorboxは使用しない)
    unless request.smart_phone?
      render layout: false
    end
  end

  def update_from_slideshow
    @photo.update_attributes(photo_params)
  end


  # PUT /photos/1
  # PUT /photos/1.json
  def update
    respond_to do |format|
      if @photo.update_attributes(photo_params)
        format.html { redirect_to [@photo.album, @photo], notice: '写真情報を変更しました。' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo.destroy
    @album = @photo.album

    respond_to do |format|
      format.html { redirect_to @album, notice: "写真を削除しました。" }
      format.json { head :ok }
    end
  end

  def create_comment
    if params[:content].blank?
      @error_message = 'コメントを入力しないと投稿できません'
      render 'shared/error_alert.js'
      return
    end

    params.merge!(Mutter.extra_params(current_user, request))
    @photo = Photo.find(params[:id])

    @photo.create_comment_by_mutter(comment_params)
    @photo.update_attributes(:last_comment_at => Time.now)

    UpdateHistory.for_creating_comment(@photo.album, UpdateHistory::ALBUMPHOTO_COMMENT, current_user.id)

    # 「更新情報一括閲覧」用に、AlbumでなくPhotoを対象とする
    UpdateHistory.for_creating_comment(@photo, UpdateHistory::ALBUMPHOTO_COMMENT_FOR_PHOTO, current_user.id)
   end

  def destroy_comment
    Mutter.find(params[:mutter_id]).destroy
    @photo = Photo.find(params[:id])
    UpdateHistory.for_destroying_comment(@photo.album, UpdateHistory::ALBUMPHOTO_COMMENT, current_user.id, @photo.mutter_comments.last)
    UpdateHistory.for_destroying_comment(@photo, UpdateHistory::ALBUMPHOTO_COMMENT_FOR_PHOTO, current_user.id, @photo.mutter_comments.last)
    render 'create_comment.js'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_photo
      @photo = Photo.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def photo_params
      params.require(:photo).permit(:image, :exif_at, :user_id, :album_id, :title, :last_comment_at, :description)
  end

  def comment_params
    params.permit(:content, :user_id, :ua, :for_sort_at)
  end

end
