# -*- coding: utf-8 -*-
class HistoryComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :history

  validates :content, :presence => true
end
