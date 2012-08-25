# -*- coding: utf-8 -*-
class History < ActiveRecord::Base
  belongs_to :user
  has_many :history_comments

  validates :content, :presence => true

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
