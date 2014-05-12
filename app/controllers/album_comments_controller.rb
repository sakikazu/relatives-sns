class AlbumCommentsController < ApplicationController
  before_filter :authenticate_user!

  # POST /album_comments
  # POST /album_comments.json
  def create
    @album_comment = AlbumComment.new(album_comment_params)
    @album_comment.user_id = current_user.id
    @album_comment.save
    @album = @album_comment.album

    #UpdateHistory
    action = UpdateHistory.where(:user_id => current_user.id, :action_type => UpdateHistory::ALBUM_COMMENT, :content_id => @album.id).first
    if action
      action.update_attributes(:updated_at => Time.now)
    else
      @album.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::ALBUM_COMMENT)
    end

  end

  # DELETE /album_comments/1
  # DELETE /album_comments/1.json
  def destroy
    @album_comment = AlbumComment.find(params[:id])
    @album_comment.destroy
    @album = @album_comment.album
    @destroy_flg = true
    render 'create.js'
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def album_comment_params
    params.require(:album_comment).permit(:album_id, :content)
  end
end
