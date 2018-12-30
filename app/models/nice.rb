# == Schema Information
#
# Table name: nices
#
#  id            :integer          not null, primary key
#  asset_type    :string(255)
#  comment       :text(65535)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  asset_id      :integer
#  niced_user_id :integer
#  user_id       :integer
#

class Nice < ApplicationRecord
  belongs_to :user
  belongs_to :asset, :polymorphic => true
end
