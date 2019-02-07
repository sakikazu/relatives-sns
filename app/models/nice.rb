# == Schema Information
#
# Table name: nices
#
#  id            :integer          not null, primary key
#  asset_type    :string(255)
#  comment       :text(65535)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  asset_id      :integer
#  niced_user_id :integer
#  user_id       :integer
#

class Nice < ApplicationRecord
  belongs_to :user
  belongs_to :asset, :polymorphic => true

  def self.niced_users
    users = select('distinct niced_user_id').map{ |n| User.find(n.niced_user_id) rescue nil }
    users.select{ |user| user.present? }
  end

  def self.nicing_users
    # todo: このjoinは働いてるのか？SQLはたくさん飛んでしまってるのでリファクタリングしてみる
    users = joins(:user).select('distinct user_id').map{ |n| User.find(n.user_id) rescue nil }
    users.select{ |user| user.present? }
  end
end
