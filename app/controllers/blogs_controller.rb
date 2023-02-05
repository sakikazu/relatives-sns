class BlogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_blog, only: [:show, :edit, :update, :destroy, :create_comment]
  before_action :init
  before_action :set_ups_data, only: [:show]

  # GET /blogs
  # GET /blogs.xml
  def index
    user = nil
    if params[:username] && (params[:username] != current_user.username)
      @user_selected = true
      user = User.find_by_username(params[:username])
      @page_title = "#{user.dispname}の日記"
    else
      user = current_user
      @page_title = "自分の日記"
    end
    page_per = Rails.env.production? ? 10 : 3
    @blogs = user.blogs.recent.page(params[:page]).per(page_per)

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
    @blog = Blog.new(blog_params)
    @blog.user_id = current_user.id

    respond_to do |format|
      if @blog.save
        if params[:image]
          @blog.blog_images.create(blog_image_params)
        end

        @blog.update_histories.create(user_id: current_user.id, action_type: UpdateHistory::BLOG_CREATE)

        format.html { redirect_to @blog, notice: '日記を投稿しました。' }
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
    respond_to do |format|
      if @blog.update(blog_params)
        if params[:image]
          @blog.blog_images.create(blog_image_params)
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

    @blog.comments.create(comment_params.merge(user_id: current_user.id))
    UpdateHistory.for_creating_comment(@blog, UpdateHistory::BLOG_COMMENT, current_user.id)
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
    redirect_to blog_path(blog)
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
    params.require(:blog).permit(:title, :content)
  end

  def blog_image_params
    params.require(:image).permit(:image)
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

end
