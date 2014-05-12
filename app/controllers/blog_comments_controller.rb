class BlogCommentsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @blog = Blog.find(params[:blog_id])
    comment = @blog.blog_comments.new(blog_comment_params)
    comment.blog_id = params[:blog_id]
    comment.user_id = current_user.id
    comment.save

    #UpdateHistory
    action = UpdateHistory.where(:user_id => current_user.id, :action_type => UpdateHistory::BLOG_COMMENT, :content_id => @blog.id).first
    if action
      action.update_attributes(:updated_at => Time.now)
    else
      @blog.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::BLOG_COMMENT)
    end

    # PCの場合はAjaxなのでcreate.jsが呼ばれる
    if request.mobile?
      redirect_to @blog, notice: 'コメントしました。'
    end
  end

  def destroy
    @blog = Blog.find(params[:blog_id])
    comment = BlogComment.find(params[:id])
    comment.destroy
    render "create.js"
    # redirect_to blog_path(blog_id)
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def blog_comment_params
      params.require(:blog_comment).permit(:content)
  end
end
