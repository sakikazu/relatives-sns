# -*- coding: utf-8 -*-
class PhotoComment < ActiveRecord::Base
  belongs_to :photo
  belongs_to :user

  attr_accessible :user_id, :photo_id, :content
end
