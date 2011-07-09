class BlogsController < ApplicationController
  before_filter :require_user
  before_filter :page_title

  hankaku_filter

  # GET /blogs
  # GET /blogs.xml
  def index
    if params[:username] && (params[:username] != current_user.login)
      @user = User.find_by_login(params[:username])
      @blogs = Blog.paginate(:conditions => {:user_id => @user.id}, :page => params[:page], :per_page => 10, :order => "id DESC")
    else
      @blogs = Blog.paginate(:conditions => {:user_id => current_user.id}, :page => params[:page], :per_page => 10, :order => "id DESC")
    end

    @blog_count_by_user = []
    tmp1 = Blog.count(:group => :user_id)
    tmp2 = Blog.maximum(:created_at, :group => :user_id, :order => "created_at DESC")
    tmp2.each do |user_id, val|
      user = User.find_by_id(user_id)
      @blog_count_by_user << [user, tmp1[user_id], val]
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @blogs }
    end
  end

  def index_mobile
    if params[:username] && (params[:username] != current_user.login)
      @user = User.find_by_login(params[:username])
      @blogs = Blog.paginate(:conditions => {:user_id => @user.id}, :page => params[:page], :per_page => 5, :order => "id DESC")
    else
      @blogs = Blog.paginate(:conditions => {:user_id => current_user.id}, :page => params[:page], :per_page => 5, :order => "id DESC")
    end
    @content_title = (@user ? @user.dispname : "自分") + "の日記"

    set_header
    render :action => :index_mobile, :layout => "mobile"
  end

  def everyone_mobile
    @content_title = "みんなの日記(更新日順)"
    @blog_count_by_user = []
    tmp1 = Blog.count(:group => :user_id)
    tmp2 = Blog.maximum(:created_at, :group => :user_id, :order => "created_at DESC")
    tmp2.each do |user_id, val|
      user = User.find_by_id(user_id)
      @blog_count_by_user << [user, tmp1[user_id], val]
    end

    set_header
    render :action => :everyone_mobile, :layout => "mobile"
  end

  def show_mobile
    @blog = Blog.find(params[:id])
    @content_title = @blog.user.dispname + "の日記"
    set_header
    render :action => :show_mobile, :layout => "mobile"
  end

  # GET /blogs/1
  # GET /blogs/1.xml
  def show
    #更新情報一括閲覧用
    @ups_page, @ups_action_info = update_allview_helper(params[:ups_page], params[:ups_id])

    @blog = Blog.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @blog }
    end
  end

  # GET /blogs/new
  # GET /blogs/new.xml
  def new
    @blog = Blog.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @blog }
    end
  end

  def new_mobile
    @content_title = "日記を書く"
    @blog = Blog.new
    set_header
    render :action => :new_mobile, :layout => "mobile"
  end

  # GET /blogs/1/edit
  def edit
    @blog = Blog.find(params[:id])
  end

  def edit_mobile
    @content_title = "日記を編集する"
    @blog = Blog.find(params[:id])
    set_header
    render :action => :edit_mobile, :layout => "mobile"
  end

  # POST /blogs
  # POST /blogs.xml
  def create
    params[:blog][:user_id] = current_user.id
    @blog = Blog.new(params[:blog])

    if request.mobile?
      @blog.save
      @blog.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::BLOG_CREATE)
      redirect_to :action => :show_mobile, :id => @blog.id
      return
    end

    respond_to do |format|
      if @blog.save
        if params[:image]
          image = BlogImage.new(params[:image])
          @blog.blog_images << image
        end

        @blog.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::BLOG_CREATE)

        format.html { redirect_to(@blog, :notice => '作成しました') }
        format.xml  { render :xml => @blog, :status => :created, :location => @blog }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @blog.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /blogs/1
  # PUT /blogs/1.xml
  def update
    @blog = Blog.find(params[:id])

    if request.mobile?
      @blog.update_attributes(params[:blog])
      redirect_to :action => :show_mobile, :id => @blog.id
      return
    end

    respond_to do |format|
      if @blog.update_attributes(params[:blog])
        if params[:image]
          image = BlogImage.new(params[:image])
          @blog.blog_images << image
        end

        format.html { redirect_to(@blog, :notice => '更新しました') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @blog.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /blogs/1
  # DELETE /blogs/1.xml
  def destroy
    @blog = Blog.find(params[:id])
    @blog.destroy

    redirect_to(blogs_url)
  end

  def destroy_mobile
    @blog = Blog.find(params[:id])
    @blog.destroy

    set_header
    redirect_to :action => :index_mobile, :layout => "mobile"
  end

  def destroy_confirm_mobile
    @content_title = "削除の確認"
    @blog = Blog.find(params[:id])
    set_header
    render :action => :destroy_confirm_mobile, :layout => "mobile"
  end

  def create_comment
    if params[:comment].blank?
      render :text => "", :status => 500
      return
    end

    @blog = Blog.find(params[:blog_id])
    @blog.blog_comments.create(:user_id => current_user.id, :content => params[:comment])

    #UpdateHistory
    uh = UpdateHistory.find(:first, :conditions => {:user_id => current_user.id, :action_type => UpdateHistory::BLOG_COMMENT, :assetable_id => @blog.id})
    if uh
      uh.update_attributes(:updated_at => Time.now)
    else
      @blog.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::BLOG_COMMENT)
    end

    if request.mobile?
      set_header
      render :action => :show_mobile, :layout => "mobile"
    end
  end

  def destroy_comment
    @bcom = BlogComment.find(params[:id])
    blog = @bcom.blog
    @bcom.destroy

    if request.mobile?
      set_header
      redirect_to :action => :show_mobile, :id => blog.id, :layout => "mobile"
    else
      redirect_to :action => :show, :id => blog.id
    end
  end

  def destroy_comment_confirm_mobile
    @content_title = "削除の確認"
    @bcom = BlogComment.find(params[:id])
    set_header
    render :action => :destroy_comment_confirm_mobile, :layout => "mobile"
  end

  def destroy_image
    @bi = BlogImage.find(params[:id])
    blog = @bi.blog
    @bi.destroy
    redirect_to :action => :show, :id => blog.id
  end

private
  def page_title
    @page_title = "日記"
  end

end
