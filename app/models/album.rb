class Album < ActiveRecord::Base
  belongs_to :user
  belongs_to :thumb, :class_name => "Photo", :foreign_key => :thumb_id
  has_many :album_comments
  has_many :photos
  has_many :update_histories, :as => :content, :dependent => :destroy

  attr_accessible :title, :description, :thumb_id, :user_id

  #sakikazu ↓これがあると、このモデルの関連ができなくなり、処理にめっちゃ時間がかかり、Stackがあふれたみたいなエラーが出る…なぜ
  # acts_as_paranoid
  attr_accessor :sort_at

  #写真がアップされた日時の降順でアルバムをソートする
  def self.sort_upload
    buf = Photo.maximum(:created_at, :group => :album_id)
    albums = Album.all.map{|a| a.sort_at = (buf[a.id] || a.created_at); a}
    albums.sort{|a,b| b.sort_at <=> a.sort_at}
  end
end
