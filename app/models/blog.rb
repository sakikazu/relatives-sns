class Blog < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  has_many :blog_comments
  has_many :blog_images
  has_many :update_histories, :as => :content, :dependent => :destroy
  has_many :nices, :as => :asset

  default_scope {order("created_at DESC")}
end
