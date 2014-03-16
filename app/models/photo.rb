# -*- coding: utf-8 -*-
class Photo < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :album
  belongs_to :user
  has_many :photo_comments
  has_many :nices, :as => :asset
  has_many :update_histories, :as => :content, :dependent => :destroy

  attr_accessible :image, :exif_at, :user_id, :album_id, :title, :last_comment_at, :description

  content_name = "album"
  has_attached_file :image,
    :styles => {
      :thumb => "150x150>",
      :large => "800x800>"
    },
    :convert_options => { :thumb => ['-quality 70', '-strip']}, #50じゃノイズきつい
    :url => "/upload/#{content_name}/:album/:id/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:album/:id/:style/:basename.:extension"


  validates_attachment :image, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "application/octet-stream"] }

  #全写真からただランダムに抽出する
  def self.rnd_photos
    photos = self.includes(:album).order("RAND()").limit(15).map{|photo| photo if photo.album.present?}
#sakikazu 上でalbumが実際に存在しなかったら、if文のせいで(？)、nilが入ってしまう。なので削除しておく
# ★これってどうしようかな。アルバムない写真を全削除？上のはもっと良いやり方ある？これは注意すべき事象なので、解析してメモっておきたい
    photos.delete_if{|p| p == nil}
    photos
  end


end
