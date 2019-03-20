# == Schema Information
#
# Table name: comments
#
#  id          :integer          not null, primary key
#  content     :text(65535)
#  parent_type :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  mutter_id   :integer
#  parent_id   :integer
#  photo_id    :integer
#  user_id     :integer
#

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :parent, :polymorphic => true

  validates_presence_of :content

end
