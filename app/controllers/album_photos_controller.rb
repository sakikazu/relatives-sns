class AlbumPhotosController < ApplicationController
  before_filter :require_user, :except => [:create] #sakikazu memo 特に意味ないかな・・for uploadify
  #layout "simple", :only => :slideshow

  # GET /album_photos
  # GET /album_photos.xml
  def index
    @album_photos = AlbumPhoto.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @album_photos }
    end
  end

  # GET /album_photos/1
  # GET /album_photos/1.xml
  def show
    @album_photo = AlbumPhoto.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @album_photo }
    end
  end

  # GET /album_photos/new
  # GET /album_photos/new.xml
  def new
    @album_photo = AlbumPhoto.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @album_photo }
    end
  end

  # GET /album_photos/1/edit
  def edit
    @album_photo = AlbumPhoto.find(params[:id])
  end

  # POST /album_photos
  # POST /album_photos.xml
  def create

    params[:album_photo] = {}
    params[:album_photo][:attach] = params['Filedata'] #paperclip
    params[:album_photo][:exif_at] = EXIFR::JPEG.new(params['Filedata'].path).date_time
    params[:album_photo][:user_id] = params['user_id']
    params[:album_photo][:album_id] = params['album_id']
    params[:album_photo][:title] = "[無題]" 
    @album_photo = AlbumPhoto.new(params[:album_photo])

    #UpdateHistory
    uh = UpdateHistory.find(:first, :conditions => {:user_id => @album_photo.user_id, :action_type => UpdateHistory::ALBUMPHOTO_CREATE, :assetable_id => @album_photo.album.id})
    if uh
      uh.update_attributes(:updated_at => Time.now)
    else
      @album_photo.album.update_histories << UpdateHistory.create(:user_id => @album_photo.user_id, :action_type => UpdateHistory::ALBUMPHOTO_CREATE)
    end

    respond_to do |format|
      if @album_photo.save
        format.html { redirect_to(@album_photo, :notice => 'AlbumPhoto was successfully created.') }
        format.xml  { render :xml => @album_photo, :status => :created, :location => @album_photo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @album_photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /album_photos/1
  # PUT /album_photos/1.xml
  def update
    @album_photo = AlbumPhoto.find(params[:id])

    respond_to do |format|
      if @album_photo.update_attributes(params[:album_photo])
        format.html { redirect_to({:controller => :albums, :action => :show, :id => @album_photo.album.id}, :notice => '写真情報を更新しました.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @album_photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /album_photos/1
  # DELETE /album_photos/1.xml
  def destroy
    @album_photo = AlbumPhoto.find(params[:id])
    album_id = @album_photo.album.id
    @album_photo.destroy

    respond_to do |format|
      format.html { redirect_to({:controller => :albums, :action => :show, :id => album_id}, :notice => '写真を削除しました.') }
      format.xml  { head :ok }
    end
  end

  def slideshow
    @from_top_flg = true if params[:top].present?
    @album_photo = AlbumPhoto.find(params[:id])
    @album_photo_comment = AlbumPhotoComment.new(:user_id => current_user.id, :album_photo_id => @album_photo.id)
    render :layout => "simple"
  end

  def update_from_slideshow
    @album_photo = AlbumPhoto.find(params[:id])
    @album_photo.update_attributes(params[:album_photo])
  end

  def create_comment
    exit if params[:album_photo_comment][:content].blank?
    comment = AlbumPhotoComment.create(params[:album_photo_comment])
    @album_photo = comment.album_photo 
    @album_photo.update_attributes(:last_comment_at => Time.now)

    #UpdateHistory
    uh = UpdateHistory.find(:first, :conditions => {:user_id => current_user.id, :action_type => UpdateHistory::ALBUMPHOTO_COMMENT, :assetable_id => @album_photo.album.id})
    if uh
      uh.update_attributes(:updated_at => Time.now)
    else
      @album_photo.album.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::ALBUMPHOTO_COMMENT)
    end
  end

  def destroy_comment
    com = AlbumPhotoComment.find(params[:id])
    @album_photo = com.album_photo
    com.destroy

    ### sakikazu memo
    #AlbumPhotoCommentのmodelには
    #has_many :update_histories, :as => :assetable, :dependent => :destroy
    #とはできない(よね？ひもづいてないから)
    #もしひもづけて削除できたとしても、例えばアルバムに2回コメントして、2回目のを削除した場合、1回目の分も削除されちゃうのでダメ
    
    #UpdateHistoryに、同じアルバムで同じ人のコメントがなければ削除ってやっていいけど、
    #もし3日前のコメントがあった場合、現在のコメントでupdated_atが上書かれるが、その時は削除されないので結局ダメ。難しい。
  end

end
