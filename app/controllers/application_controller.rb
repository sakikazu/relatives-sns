class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  class Forbidden < ActionController::ActionControllerError; end
  include ErrorHandlers if Rails.env.production?

  # 発行されたSQLを取得する
  # todo 何やってるかさぱりわからん
  def watch_queries
    events = []
    callback = -> name,start,finish,id,payload { events << payload[:sql] }
    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      yield
    end
    events
  end


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

  # ログインユーザーの最終リクエスト時間を更新する
  def update_request_at
    # [memo] update_attributeだと、validateなしで更新することができる。update_attributesはvalidateあり。
    current_user.update_attribute(:last_request_at, Time.now) if current_user.present?
  end

end
