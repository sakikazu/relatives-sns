class PhotoCommentsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_photo_comment, only: [:destroy]

  # POST /photo_comments
  # POST /photo_comments.json
  def create
    @photo_comment = PhotoComment.create(photo_comment_params)
    @photo = @photo_comment.photo
    @photo.update_attributes(:last_comment_at => Time.now)

    #UpdateHistory(mutters#indexの更新一覧表示用。たぶん)
    action = UpdateHistory.where(:user_id => current_user.id, :action_type => UpdateHistory::ALBUMPHOTO_COMMENT, :content_id => @photo.album.id).first
    if action
      action.update_attributes(:updated_at => Time.now)
    else
      @photo.album.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::ALBUMPHOTO_COMMENT)
    end

    #UpdateHistory(更新内容一括表示機能のための更新データ)
    action = UpdateHistory.where(:user_id => current_user.id, :action_type => UpdateHistory::ALBUMPHOTO_COMMENT_FOR_PHOTO, :content_id => @photo.id).first
    if action
      action.update_attributes(:updated_at => Time.now)
    else
      @photo.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::ALBUMPHOTO_COMMENT_FOR_PHOTO)
    end

   end

  # DELETE /photo_comments/1
  # DELETE /photo_comments/1.json
  def destroy
    @photo_comment.destroy
    @photo = @photo_comment.photo
    @destroy_flg = true
    render 'create.js'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_photo_comment
      @photo_comment = PhotoComment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def photo_comment_params
      params.require(:photo_comment).permit(:user_id, :photo_id, :content)
  end
end
