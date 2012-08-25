# -*- coding: utf-8 -*-
class BlogComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog
end
