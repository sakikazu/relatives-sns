# -*- coding: utf-8 -*-
class MovieComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :movie
end
