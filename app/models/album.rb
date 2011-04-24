class Album < ActiveRecord::Base
  belongs_to :user
  has_many :album_photos
  has_many :update_histories, :as => :assetable, :dependent => :destroy
  belongs_to :use1_photo, :class_name => "AlbumPhoto", :foreign_key => :use1_id

  attr_accessor :sort_at

  acts_as_paranoid

  #写真がアップされた日時の降順でアルバムをソートする
  def self.sort_upload
    buf = AlbumPhoto.maximum(:created_at, :group => :album_id)
    albums = Album.all.map{|a| a.sort_at = (buf[a.id] || a.created_at); a}
    albums.sort{|a,b| b.sort_at <=> a.sort_at}
  end

  #全写真からただランダムに抽出する
  def self.rnd_photos
    AlbumPhoto.includes(:album).order("RAND()").limit(30)
  end
end
