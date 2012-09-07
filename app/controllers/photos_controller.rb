# -*- coding: utf-8 -*-
class PhotosController < ApplicationController
  before_filter :authenticate_user!, :except => [:create]  #sakikazu これがないとcreateできない。 for uploadify

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
  def show
    @photo = Photo.find(params[:id])
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
    @photo = Photo.find(params[:id])
  end

  # POST /photos
  # POST /photos.json
  def create
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
    @photo = Photo.new(params[:photo])

# ここは認証を解除しているからcurrent_userは使えないので、@photo.userを使う
    #UpdateHistory
    action = UpdateHistory.where(:user_id => @photo.user.id, :action_type => UpdateHistory::ALBUMPHOTO_CREATE, :content_id => @photo.album.id).first
    if action
      action.update_attributes(:updated_at => Time.now)
    else
      @photo.album.update_histories << UpdateHistory.create(:user_id => @photo.user.id, :action_type => UpdateHistory::ALBUMPHOTO_CREATE)
    end

    respond_to do |format|
      if @photo.save
        format.html { redirect_to([@photo.album, @photo], :notice => 'Photo was successfully created.') }
        format.xml  { render :xml => @photo, :status => :created, :location => @photo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  def slideshow
    @from_top_flg = true if params[:top].present?
    @photo = Photo.find(params[:id])
    @photo_comment = PhotoComment.new(:user_id => current_user.id, :photo_id => @photo.id)
    render layout: false
    #sakikazu PCからはJSをincludeしないレイアウトを読み込んで、Ajaxの多重書き込みを防ぐ(※スマホからは見づらいのでcolorboxは使用しない)
    # unless request.smart_phone?
      # render :layout => 'non_include'
    # end
  end

  def update_from_slideshow
    @photo = Photo.find(params[:id])
    @photo.update_attributes(params[:photo])
  end


  # PUT /photos/1
  # PUT /photos/1.json
  def update
    @photo = Photo.find(params[:id])

    respond_to do |format|
      if @photo.update_attributes(params[:photo])
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
    @photo = Photo.find(params[:id])
    @photo.destroy
    @album = @photo.album

    respond_to do |format|
      format.html { redirect_to @album, notice: "写真を削除しました。" }
      format.json { head :ok }
    end
  end
end
