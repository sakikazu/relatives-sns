# -*- coding: utf-8 -*-
class LoginHistory < ActiveRecord::Base
  belongs_to :user
end
