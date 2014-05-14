class PhotosController < ApplicationController
  before_filter :authenticate_user!, :except => [:create]  #sakikazu これがないとcreateできない。 for uploadify
  before_action :set_photo, only: [:show, :edit, :update, :destroy, :slideshow, :update_from_slideshow]

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
    #更新情報一括閲覧用
    @ups_page, @ups_action_info = update_allview_helper(params[:ups_page], params[:ups_id])

    @photo_comment = PhotoComment.new(:user_id => current_user.id, :photo_id => @photo.id)

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
    p params
    params[:photo] = {}
    params[:photo][:image] = params['Filedata'] #paperclip
    #memo 「date_time」だと、写真の更新日付になってしまうことがあった。「exif.date_time_digitized」で取得すること
    #memo 追記 EXIFがない画像への対処を入れた
    e_data = EXIFR::JPEG.new(params['Filedata'].path) rescue err_flg = true
    if err_flg.blank?
      params[:photo][:exif_at] = ((e_data.exif && e_data.exif.date_time_digitized) || e_data.date_time) rescue nil
    end
    params[:photo][:user_id] = params['user_id']
    params[:photo][:album_id] = params['album_id']
    params[:photo][:title] = "[無題]"
    @photo = Photo.new(photo_params)

# ここは認証を解除しているからcurrent_userは使えないので、@photo.userを使う
    #UpdateHistory
    action = UpdateHistory.where(:user_id => @photo.user.id, :action_type => UpdateHistory::ALBUMPHOTO_CREATE, :content_id => @photo.album.id).first
    if action
      action.update_attributes(:updated_at => Time.now)
    else
      @photo.album.update_histories << UpdateHistory.create(:user_id => @photo.user.id, :action_type => UpdateHistory::ALBUMPHOTO_CREATE)
    end

    # memo Ajaxでのpostはsaveのエラーが画面には表示されないので、自分で出力してあげる
    # logger.debug @photo.errors.full_messages.inspect
    # logger.debug @photo.errors.full_messages.to_sentence

    # respond_to do |format|
      # if @photo.save
        # format.html { redirect_to([@photo.album, @photo], :notice => 'Photo was successfully created.') }
        # format.xml  { render :xml => @photo, :status => :created, :location => @photo }
      # else
        # format.html { render :action => "new" }
        # format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
      # end
    # end
  end

  # PCからはcolorboxで使用する前提。スマホからは一つのページとして表示する
  def slideshow
    @from_top_flg = true if params[:top].present?
    @photo_comment = PhotoComment.new(:user_id => current_user.id, :photo_id => @photo.id)
    #sakikazu PCからはJSをincludeしないようにレイアウトをオフにして、Ajaxの多重書き込みを防ぐ(※スマホからは見づらいのでcolorboxは使用しない)
    unless request.smart_phone?
      render layout: false
    end
  end

  def update_from_slideshow
    @photo.update_attributes(params[:photo])
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

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_photo
      @photo = Photo.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def photo_params
      params.require(:photo).permit(:image, :exif_at, :user_id, :album_id, :title, :last_comment_at, :description)
  end

end
