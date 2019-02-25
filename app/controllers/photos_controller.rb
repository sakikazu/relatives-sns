class PhotosController < ApplicationController
  before_action :authenticate_user!, :except => [:create]  #sakikazu これがないとcreateできない。 for uploadify
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
  # todo 2014/05/17 Firefoxだと422エラーになる件
  # 下記対策が有用そうだけど、大変ぽいので・・断念
  # ref: Uploadify with Paperclip on Rails Tutorial | Old Blind Pew http://martinjhawkins.wordpress.com/2013/10/07/uploadify-with-paperclip-on-rails-tutorial/
  # ref: Rails 4 + Uploadify + Paperclip | Vignesh's Blog http://vignesh.info/blog/rails-4-uploadify-paperclip/
  def create
    params[:photo] = {}
    params[:photo][:image] = params['Filedata'] #paperclip
    params[:photo][:exif_at] = Photo::set_exif_at(params['Filedata'].path)
    params[:photo][:user_id] = params['user_id']
    params[:photo][:album_id] = params['album_id']
    params[:photo][:title] = "[無題]"
    @photo = Photo.new(photo_params)

# ここは認証を解除しているからcurrent_userは使えないので、@photo.userを使う
    UpdateHistory.create_or_update(@photo.user.id, UpdateHistory::ALBUMPHOTO_CREATE, @photo.album)

    # memo Ajaxでのpostはsaveのエラーが画面には表示されないので、自分で出力してあげる
    # あと、pメソッドでログに出力されないため、loggerを使用する
    # logger.debug @photo.errors.full_messages.inspect
    # logger.debug @photo.errors.full_messages.to_sentence

    @photo.save
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

    UpdateHistory.create_or_update(current_user.id, UpdateHistory::ALBUMPHOTO_COMMENT, @photo.album)

    # 「更新情報一括閲覧」用
    UpdateHistory.create_or_update(current_user.id, UpdateHistory::ALBUMPHOTO_COMMENT_FOR_PHOTO, @photo)
   end

  def destroy_comment
    Mutter.find(params[:mutter_id]).destroy
    @photo = Photo.find(params[:id])
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
