class Blog < ActiveRecord::Base
  belongs_to :user
  has_many :blog_comments
  has_many :blog_images
  has_many :update_histories, :as => :assetable, :dependent => :destroy
  has_many :nices, :as => :nice

  acts_as_paranoid
end
