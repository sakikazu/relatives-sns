class Blog < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  belongs_to :mutter
  has_many :comments, as: :parent
  has_many :blog_images
  has_many :nices, :as => :asset

  # todo
  has_many :blog_comments
  has_many :update_histories, :as => :content, :dependent => :destroy

  default_scope {order("created_at DESC")}
end
