# -*- coding: utf-8 -*- 
class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :select_layout
  include Jpmobile::ViewSelector #Viewの自動振り分け

private

  # トップページから、更新情報を元に更新内容を一括で閲覧するためのデータ取得
  def update_allview_helper(page, ups_id) 
    if page.present? and ups_id.present?
      up = UpdateHistory.find(ups_id)
      ai = UpdateHistory::ACTION_INFO[up.action_type]
      #ai.infoから先頭一文字(「に」とか入ってるから)を除く
      msg = "#{up.user.dispname}が#{ai[:info][1, ai[:info].length]}"
      return page.to_i, msg
    else
      return nil, nil
    end
  end


  # ガラケー用
  def redirect_if_mobile
    if request.mobile?
      pa = params.dup
      pa[:controller] = "mobile"
      redirect_to pa
    end
  end

  def select_layout
    if devise_controller?
      if request.mobile?
        false
      else
        "application"
      end
    else
      if request.mobile?
        "mobile"
      else
        "application"
      end
    end
  end

end
