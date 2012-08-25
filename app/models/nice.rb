# -*- coding: utf-8 -*-
class Nice < ActiveRecord::Base
  belongs_to :user
  belongs_to :nice, :polymorphic => true
end
