# == Schema Information
#
# Table name: blogs
#
#  id         :integer          not null, primary key
#  content    :text(65535)
#  deleted_at :datetime
#  title      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  mutter_id  :integer
#  user_id    :integer
#

class Blog < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  belongs_to :mutter, optional: true
  has_many :comments, as: :parent
  has_many :blog_images
  has_many :nices, :as => :asset
  has_many :update_histories, :as => :content, :dependent => :destroy

  default_scope {order("created_at DESC")}
end
