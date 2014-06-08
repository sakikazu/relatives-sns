class Album < ActiveRecord::Base
  belongs_to :user
  belongs_to :owner, :class_name => "User", :foreign_key => :owner_id
  belongs_to :thumb, :class_name => "Photo", :foreign_key => :thumb_id
  has_many :photos
  has_many :movies
  has_many :update_histories, :as => :content, :dependent => :destroy
  has_many :album_comments
  has_many :comments, as: :parent

  validates :title, presence: true

  acts_as_paranoid

  attr_accessor :sort_at, :sort_flg, :media_filter

  scope :without_owner, lambda {where("owner_id is NULL")}
  scope :with_owner, lambda {where("owner_id is not NULL")}

  # 写真、動画がアップされた日時の降順でアルバムをソートする
  def self.sort_upload
    photo = Photo.group(:album_id).maximum(:created_at)
    movie = Movie.group(:album_id).maximum(:created_at)
    albums = Album.all.map do |a|
      if photo[a.id].present? or movie[a.id].present?
        media_max_created_at = [(photo[a.id] || Time.mktime(0)), (movie[a.id] || Time.mktime(0))].max
      end
      a.sort_at = (media_max_created_at || a.created_at);
      a
    end
    albums.sort{|a,b| b.sort_at <=> a.sort_at}
  end

  # 各ユーザーがアルバム機能以外からアップする写真専用のアルバムを作成する
  def self.create_having_owner(user)
    self.create(title: user.dispname + "のアルバム", owner_id: user.id, user_id: user.id)
  end
end
