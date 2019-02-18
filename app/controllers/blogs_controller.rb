class BlogsController < ApplicationController
  before_action :authenticate_user!, :except => [:create_images]  #sakikazu これがないとcreateアクションの中に入ることすらない。 for uploadify
  before_action :set_blog, only: [:show, :edit, :update, :destroy]
  before_action :init
  before_action :set_ups_data, only: [:show]

  # GET /blogs
  # GET /blogs.xml
  def index
    if params[:username] && (params[:username] != current_user.username)
      @user = User.find_by_username(params[:username])
      @blogs = Blog.joins(:user).where(user_id: @user.id).page(params[:page]).per(15)
      @page_title = "#{@user.dispname}の日記"
    else
      @blogs = Blog.joins(:user).where(user_id: current_user.id).page(params[:page]).per(15)
      @page_title = "自分の日記"
    end

    # ブログの最終作成日が直近の人の順に、ブログ記事のカウントとともにデータをセットする
    @blog_count_by_user = []
    tmp1 = Blog.group(:user_id).count
    tmp2 = Blog.group(:user_id).order("created_at DESC").maximum(:created_at)
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
  # GET /blogs/1.json
  def show
    @new_comment = @blog.comments.build

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @blog }
    end
  end


  # GET /blogs/new
  # GET /blogs/new.json
  def new
    @blog = Blog.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @blog }
    end
  end

  # GET /blogs/1/edit
  def edit
  end

  # POST /blogs
  # POST /blogs.json
  def create
    params[:blog][:user_id] = current_user.id
    @blog = Blog.new(blog_params)

    respond_to do |format|
      if @blog.save
        # todo imageの持ち方を変えたい
        if params[:image]
          image = BlogImage.new(blog_image_params)
          @blog.blog_images << image
        end

        @blog.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::BLOG_CREATE)

        if request.mobile?
          format.html { redirect_to({:action => :show_mobile, :id => @blog.id}, notice: '日記を投稿しました。') }
        else
          format.html { redirect_to @blog, notice: '日記を投稿しました。' }
        end
        format.json { render json: @blog, status: :created, location: @blog }
      else
        format.html { render action: "new" }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /blogs/1
  # PUT /blogs/1.xml
  def update
    if request.mobile?
      @blog.update_attributes(blog_params)
      redirect_to :action => :show_mobile, :id => @blog.id
      return
    end

    respond_to do |format|
      if @blog.update_attributes(blog_params)
        if params[:image]
          image = BlogImage.new(blog_image_params)
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
    @blog.destroy

    redirect_to(blogs_url, notice: '日記を削除しました')
  end

  def create_comment
    if params[:comment][:content].blank?
      @error_message = 'コメントを入力しないと投稿できません'
      return
    end

    @comment = Comment.new(comment_params)
    @comment.user_id = current_user.id
    @comment.save
    @blog = @comment.parent

    UpdateHistory.create_or_update(current_user.id, UpdateHistory::BLOG_COMMENT, @blog)

    # PCの場合はAjaxなのでcreate.jsが呼ばれる
    if request.mobile?
      redirect_to @blog, notice: 'コメントしました。'
    end
  end

  def destroy_comment
    @bcom = Comment.find(params[:id])
    @blog = @bcom.parent
    @bcom.destroy

    render "create_comment.js"
  end

  def destroy_image
    @bi = BlogImage.find(params[:id])
    blog = @bi.blog
    @bi.destroy
    redirect_to :action => :show, :id => blog.id
  end


  private
  def init
    @page_content_type = "日記"
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_blog
    @blog = Blog.find(params[:id])
    @page_content_title = @blog.title if @blog.present?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def blog_params
    params.require(:blog).permit(:title, :content, :user_id)
  end

  def blog_image_params
    params.require(:image).permit(:image)
  end

  def comment_params
    params.require(:comment).permit(:user_id, :parent_id, :parent_type, :content)
  end

end
