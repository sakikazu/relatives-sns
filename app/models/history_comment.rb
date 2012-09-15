# -*- coding: utf-8 -*-
class HistoryComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :history

  validates :content, :presence => true

  attr_accessible :user_id, :history_id, :content
end
