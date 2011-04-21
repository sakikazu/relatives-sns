class AlbumPhoto < ActiveRecord::Base
  belongs_to :user
  belongs_to :album
  has_many :album_photo_comments

  content_name = "album"
  has_attached_file :attach,
    :styles => {
      :thumb => "150x150>",
      :large => "800x800>"
    },
    :url => "/uploads/#{content_name}/:album/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploads/#{content_name}/:album/:id/:style/:basename.:extension"

end
