class Nice < ActiveRecord::Base
  belongs_to :user
  belongs_to :asset, :polymorphic => true
end
