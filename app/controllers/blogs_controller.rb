class BlogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_blog, only: [:show, :edit, :update, :destroy]
  before_action :init
  before_action :set_ups_data, only: [:show]

  # GET /blogs
  # GET /blogs.xml
  def index
    user_id = nil
    if params[:username] && (params[:username] != current_user.username)
      @user = User.find_by_username(params[:username])
      user_id = @user.id
      @page_title = "#{@user.dispname}の日記"
    else
      user_id = current_user.id
      @page_title = "自分の日記"
    end
    @blogs = Blog.joins(:user).where(user_id: user_id).page(params[:page]).per(10)

    # ブログの最終作成日が直近の人の順に、ブログ記事のカウントとともにデータをセットする
    counts = Blog.group(:user_id).count
    latest_blogs = Blog.group(:user_id).maximum(:created_at).sort { |a, b| b[1] <=> a[1] }
    @blog_count_by_user = latest_blogs.map do |user_id, created_at|
      user = User.find_by_id(user_id)
      [user, counts[user_id], created_at]
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
    @comments = @blog.comments.select { |comment| comment.persisted? }

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

        @blog.update_histories.create(user_id: current_user.id, action_type: UpdateHistory::BLOG_CREATE)

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
    unless editable(current_user, @blog.user)
      redirect_back fallback_location: root_path, alert: '削除権限がありません。'
      return
    end

    @blog.destroy

    redirect_to(blogs_url, notice: '日記を削除しました')
  end

  def create_comment
    if params[:comment][:content].blank?
      @error_message = 'コメントを入力しないと投稿できません'
      render 'shared/error_alert.js'
      return
    end

    @comment = Comment.new(comment_params)
    @comment.user_id = current_user.id
    @comment.save
    @blog = @comment.parent

    UpdateHistory.for_creating_comment(@blog, UpdateHistory::BLOG_COMMENT, current_user.id)

    # PCの場合はAjaxなのでcreate.jsが呼ばれる
    if request.mobile?
      redirect_to @blog, notice: 'コメントしました。'
    end
  end

  def destroy_comment
    @bcom = Comment.find(params[:id])
    @blog = @bcom.parent
    @bcom.destroy
    UpdateHistory.for_destroying_comment(@blog, UpdateHistory::BLOG_COMMENT, current_user.id, @blog.comments.last)

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
