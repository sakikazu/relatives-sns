# -*- coding: utf-8 -*-
class Celebration < ActiveRecord::Base
  belongs_to :user
  has_many :mutters

  attr_accessible :anniversary_at, :user_id
end
