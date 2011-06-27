class AlbumsController < ApplicationController
  before_filter :require_user
  before_filter :page_title

  # GET /albums
  # GET /albums.xml
  def index
    case params[:sort].to_i
    when 1
      @albums = Album.sort_upload
    when 2
      @albums = Album.all(:order => "id DESC")
    else
      @albums = Album.sort_upload
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @albums }
    end
  end

  # GET /albums/1
  # GET /albums/1.xml
  def show
    @album = Album.find(params[:id])
    @sort = (params[:sort] =~ /1|2|3|4/) ? params[:sort].to_i : 1
    case @sort 
    when 1
      album_photos = @album.album_photos.order("id DESC")
    when 2
      album_photos = @album.album_photos.order("exif_at ASC")
    when 3
      album_photos = @album.album_photos.order("last_comment_at DESC")
    when 4
      album_photos = @album.album_photos.order("nices.created_at DESC").order("last_comment_at DESC")
    end
    @album_photos = album_photos.includes(:nices).paginate(:page => params[:page], :per_page => 30)

    @comment = AlbumComment.new(:user_id => current_user.id, :album_id => @album.id)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @album }
    end
  end

  # GET /albums/new
  # GET /albums/new.xml
  def new
    @album = Album.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @album }
    end
  end

  # GET /albums/1/edit
  def edit
    @album = Album.find(params[:id])
  end

  # POST /albums
  # POST /albums.xml
  def create
    params[:album][:user_id] = current_user.id
    @album = Album.new(params[:album])

    respond_to do |format|
      if @album.save
        @album.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::ALBUM_CREATE)
        format.html { redirect_to(@album, :notice => '作成されました.') }
        format.xml  { render :xml => @album, :status => :created, :location => @album }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @album.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /albums/1
  # PUT /albums/1.xml
  def update
    @album = Album.find(params[:id])

    respond_to do |format|
      if @album.update_attributes(params[:album])
        format.html { redirect_to(@album, :notice => '更新されました.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @album.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /albums/1
  # DELETE /albums/1.xml
  def destroy
    @album = Album.find(params[:id])
    @album.destroy

    respond_to do |format|
      format.html { redirect_to(albums_url) }
      format.xml  { head :ok }
    end
  end

  def title_index
    @albums = Album.sort_upload
    @photo_count = AlbumPhoto.count(:group => :album_id)
    @last_comment_at = AlbumPhoto.maximum(:last_comment_at, :group => :album_id)
  end

#現在Callされていない
  def upload_complete
    @album = Album.find(params[:id])
    redirect_to :action => :show, :id => @album.id


#UpdateHistory更新処理は、AlbumPhotosController のcreateで行っている
    #$exist_data = $this->UpdateInfo->find( array(
      #'UpdateInfo.user_id' => $this->Auth->user('id'), 
      #'action' => ACTION_ALBUMPHOTO_CREATE,
      #'ref_id' => $this->params['named']['album_id'],
      #'UpdateInfo.created BETWEEN ? AND ?' => array(date("Y/m/d", strtotime ("now")), date("Y/m/d", strtotime ("+1 day"))),
      #));

    #if(empty($exist_data)){
      #$this->UpdateInfo->create();
      #$this->UpdateInfo->save(
        #array('UpdateInfo' => array(
          #'user_id' => $this->Auth->user('id'),
          #'action' => ACTION_ALBUMPHOTO_CREATE,
          #'ref_id' => $this->params['named']['album_id'],
          #'ref_str' => $this->params['named']['album_title'],
        #))
      #);
    #}else{
      #$this->UpdateInfo->read(null, $exist_data['UpdateInfo']['id']);
      #$this->UpdateInfo->saveField('created', date("Y-m-d H:i:s"));
    #}

  end

  def download
    album = Album.find(params[:id])
    tmp = Tempfile.new('album')
    tmp_dir = tmp.path + '.dir'
    FileUtils.mkdir(tmp_dir)
    album.album_photos.each do |photo|
      if File.exist?(photo.attach.path)
        FileUtils.cp photo.attach.path, tmp_dir
      elsif File.exist?(photo.attach.path(:large))
        FileUtils.cp photo.attach.path(:large), tmp_dir
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


  def create_comment
    @album_comment = AlbumComment.create(params[:album_comment])
    @album = @album_comment.album

    #UpdateHistory
    action = UpdateHistory.where(:user_id => current_user.id, :action_type => UpdateHistory::ALBUM_COMMENT, :assetable_id => @album.id).first
    if action
      action.update_attributes(:updated_at => Time.now)
    else
      @album.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::ALBUM_COMMENT)
    end
  end

  def destroy_comment
    @album_comment = AlbumComment.find(params[:id])
    @album_comment.destroy
    @album = @album_comment.album

    respond_to do |format|
      format.html { redirect_to(album_comments_url) }
      format.js do
        render do |page|
          page.replace_html 'comments', :partial => 'comments'
        end
      end
      format.xml  { head :ok }
    end
  end


private
  def page_title
    @page_title = "アルバム"
  end

end
