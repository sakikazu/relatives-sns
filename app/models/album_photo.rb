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
    :convert_options => { :thumb => ['-quality 70', '-strip']}, #50じゃノイズきつい
    :url => "/uploads/#{content_name}/:album/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploads/#{content_name}/:album/:id/:style/:basename.:extension"

  #全写真からただランダムに抽出する
  def self.rnd_photos
    self.includes(:album).order("RAND()").limit(15).map{|photo| photo if photo.album.present?}
  end
end
