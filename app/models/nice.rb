# -*- coding: utf-8 -*-
class Nice < ActiveRecord::Base
  belongs_to :user
  belongs_to :asset, :polymorphic => true

  attr_accessible :user_id, :niced_user_id
end
