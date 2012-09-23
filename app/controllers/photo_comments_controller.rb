# -*- coding: utf-8 -*-
class PhotoCommentsController < ApplicationController
  before_filter :authenticate_user!

  # POST /photo_comments
  # POST /photo_comments.json
  def create
    @photo_comment = PhotoComment.create(params[:photo_comment])
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
    @photo_comment = PhotoComment.find(params[:id])
    @photo_comment.destroy
    @photo = @photo_comment.photo
    @destroy_flg = true
    render 'create.js'
  end
end
