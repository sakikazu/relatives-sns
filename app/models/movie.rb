class Movie < ActiveRecord::Base
  belongs_to :user
  has_many :movie_comments
  has_many :update_histories, :as => :assetable, :dependent => :destroy
  has_many :nices, :as => :nice

  validates_presence_of :movie_file_name

  acts_as_paranoid

  TYPE_NORMAL = 0
  TYPE_MODIFY = 1

  content_name = "movie"
  has_attached_file :movie,
    :url => "/uploads/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploads/#{content_name}/:id/:style/:basename.:extension"

  has_attached_file :thumb,
    :styles => {
      :thumb => "250x250>",
      :large => "600x600>"
    },
    :convert_options => { :thumb => ['-quality 80', '-strip']}, #50じゃノイズきつい
    :url => "/uploads/#{content_name}/:id/thumb/:style/:basename.:extension",
    :path => ":rails_root/public/uploads/#{content_name}/:id/thumb/:style/:basename.:extension"

end
