class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include ApplicationHelper

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

  # トップページから、UpdateHistoryを元に更新内容をそれぞれのページで閲覧するためのデータ
  def set_ups_data
    @ups_page = nil
    @ups_action_info = nil

    page = params[:ups_page]
    ups_id =  params[:ups_id]
    if page.present? and ups_id.present?
      up = UpdateHistory.find(ups_id)
      action_info = UpdateHistory::ACTION_INFO[up.action_type]
      msg = action_info[:info]
      # infoから先頭一文字(「に」とか入ってるから)を除く
      msg = msg[1, msg.length]
      @ups_action_info = "#{up.user&.dispname}が#{msg}"
      @ups_page = page.to_i
    end
  end

  # ログインユーザーの最終リクエスト時間を更新する
  def update_request_at
    # [memo] update_attributeだと、validateなしで更新することができる。updateはvalidateあり。
    current_user.update_attribute(:last_request_at, Time.now) if current_user.present?
  end

end
