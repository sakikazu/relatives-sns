# -*- coding: utf-8 -*- 
class ApplicationController < ActionController::Base
  protect_from_forgery

private

  # トップページから、更新情報を元に更新内容を一括で閲覧するためのデータ取得
  def update_allview_helper(page, ups_id) 
    if page.present? and ups_id.present?
      up = UpdateHistory.find(ups_id)
      ai = UpdateHistory::ACTION_INFO[up.action_type]
      #ai.infoから先頭一文字(utf8)を除いて付加する
      msg = "#{up.user.dispname}が#{ai[:info][3, ai[:info].length]}"
      return page.to_i, msg
    else
      return nil, nil
    end
  end

end
