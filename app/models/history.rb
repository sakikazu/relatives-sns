# == Schema Information
#
# Table name: histories
#
#  id            :integer          not null, primary key
#  about_flg     :boolean
#  content       :text(65535)
#  episode_day   :integer
#  episode_month :integer
#  episode_year  :integer
#  src_user_name :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  mutter_id     :integer
#  user_id       :integer
#

class History < ApplicationRecord
  belongs_to :user
  belongs_to :mutter
  has_many :comments, as: :parent

  validates :content, :presence => true

  scope :includes_all, lambda {includes([{:user => :user_ext}, :comments])}

  def hist_date
    if episode_year.blank?
      "時期不明"
    else
      date_str = episode_year.to_s + "年" if episode_year.present?
      date_str += episode_month.to_s + "月" if episode_month.present?
      date_str += episode_day.to_s + "日" if episode_day.present?
      date_str += "くらい" if about_flg.present?
      date_str
    end
  end

end
