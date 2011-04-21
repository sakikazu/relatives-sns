class BlogsController < ApplicationController
  before_filter :require_user
  before_filter :page_title

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

  # GET /blogs/1
  # GET /blogs/1.xml
  def show
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

  # GET /blogs/1/edit
  def edit
    @blog = Blog.find(params[:id])
  end

  # POST /blogs
  # POST /blogs.xml
  def create
    params[:blog][:user_id] = current_user.id
    @blog = Blog.new(params[:blog])

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

    respond_to do |format|
      format.html { redirect_to(blogs_url) }
      format.xml  { head :ok }
    end
  end

  def create_comment
    exit if params[:comment].blank?
    @blog = Blog.find(params[:blog_id])
    @blog.blog_comments.create(:user_id => current_user.id, :content => params[:comment])

    #UpdateHistory
    uh = UpdateHistory.find(:first, :conditions => {:user_id => current_user.id, :action_type => UpdateHistory::BLOG_COMMENT, :assetable_id => @blog.id})
    if uh
      uh.update_attributes(:updated_at => Time.now)
    else
      @blog.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::BLOG_COMMENT)
    end
  end

  def destroy_comment
    @bcom = BlogComment.find(params[:id])
    blog = @bcom.blog
    @bcom.destroy
    redirect_to :action => :show, :id => blog.id
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
