# == Schema Information
#
# Table name: user_extensions
#
#  id         :integer          not null, primary key
#  key        :string(255)
#  value      :text(65535)
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer
#

class UserExtension < ApplicationRecord
  belongs_to :user

  # つぶやきの「ひとりごと」を最後に閲覧した日時
  LAST_READ_LEAVE_ME_AT = "last_read_leave_me_at"

  # push通知用のデバイストークン、Android or iPhone
  PUSH_APNS_OR_GCM = "push_apns_or_gcm"
  PUSH_DEVICE_TOKEN = "push_device_token"


  # todo これらはクラスにまとめたい
  TYPE_APNS = "apns"
  TYPE_GCM = "gcm"
  def self.gcm_tokens
    tokens = {}
    User.includes(:user_extensions).all.each do |user|
      ext = user.user_extensions.find{|x| x[:key] == PUSH_DEVICE_TOKEN}
      next if ext.blank?
      type = user.user_extensions.find{|x| x[:key] == PUSH_APNS_OR_GCM}
      tokens[type[:value]] ||= []
      tokens[type[:value]] << ext[:value]
    end
    return tokens
  end

  def self.send_gcm(name, message)
    registration_ids = self.gcm_tokens["gcm"]
    gcm = GCM.new(Settings.GCM_API_KEY)
    # todo 「collapse_key」って？
    options = {data: {message: name + " : " + message.truncate(10)}, collapse_key: "updated_score"}
    response = gcm.send_notification(registration_ids, options)
    p response
  end
end
