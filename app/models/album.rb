# == Schema Information
#
# Table name: albums
#
#  id          :integer          not null, primary key
#  deleted_at  :datetime
#  description :text(65535)
#  title       :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  mutter_id   :integer
#  owner_id    :integer
#  thumb_id    :integer
#  user_id     :integer
#

class Album < ApplicationRecord
  belongs_to :user
  belongs_to :owner, :class_name => "User", :foreign_key => :owner_id, optional: true
  belongs_to :thumb, :class_name => "Photo", :foreign_key => :thumb_id, optional: true
  has_many :photos
  has_many :movies
  has_many :update_histories, :as => :content, :dependent => :destroy
  has_many :comments, as: :parent

  validates :title, presence: true

  acts_as_paranoid

  attr_accessor :sort_at, :sort_flg, :media_filter, :media

  scope :without_owner, lambda {where("owner_id is NULL")}
  scope :with_owner, lambda {where("owner_id is not NULL")}
  scope :id_desc, -> { order('id DESC') }
  scope :includes_general, -> { includes({user: :user_ext}, {owner: :user_ext}, :photos, :movies) }

  INDEX_COLUMNS = 5

  # 写真、動画がアップされた日時の降順でアルバムをソートする
  def self.sort_by_uploaded
    photo = Photo.group(:album_id).maximum(:created_at)
    movie = Movie.group(:album_id).maximum(:created_at)
    albums = Album.all.map do |a|
      if photo[a.id].present? or movie[a.id].present?
        media_max_created_at = [(photo[a.id] || Time.mktime(0)), (movie[a.id] || Time.mktime(0))].max
      else
        media_max_created_at = Time.mktime(0)
      end
      a.sort_at = (media_max_created_at || a.created_at);
      a
    end
    albums.sort{|a,b| b.sort_at <=> a.sort_at}
  end

  # PhotoとMovieのアップロード降順のものを混合してAlbumの順序とし、そのAlbumにPhoto、Movieの混合した要素を格納する
  #
  # TODO: リファクタリングできるかと思うがまた今度
  # NOTE: Array#zipの適した使い方：異なる集合の中から決まった位置の要素をそれぞれから取得したい場合
  def self.updated_with_media(album_count, media_count)
    photos = Photo.group(:album_id).maximum(:created_at)
    movies = Movie.group(:album_id).maximum(:created_at)
    photos = photos.sort_by{|_k, v| v}.reverse[0..album_count - 1]
    movies = movies.sort_by{|_k, v| v}.reverse[0..album_count - 1]
    photos_album_ids = photos.map { |n| n.first }
    movies_album_ids = movies.map { |n| n.first }

    album_ids = []
    movies_album_ids.zip(photos_album_ids).each do |ids|
      album_ids += ids.compact
    end
    target_album_ids = album_ids.uniq[0..album_count - 1]

    merged = {}
    target_album_ids.each do |album_id|
      album = Album.find(album_id)
      ps = album.photos.id_desc.limit(media_count)
      ms = album.movies.id_desc.limit(media_count)
      merged[album_id] = { album: album, photos: ps, movies: ms }
    end

    merged.map do |_k, v|
      album = v[:album]
      tmp_media = []
      if v[:movies].size > v[:photos].size
        base_array = v[:movies]
        another_array = v[:photos]
      else
        base_array = v[:photos]
        another_array = v[:movies]
      end
      base_array.zip(another_array).each do |media|
        tmp_media += media.compact
      end
      album.media = tmp_media[0..media_count - 1]
      album
    end
  end

  # 各ユーザーがアルバム機能以外からアップする写真専用のアルバムを作成する
  def self.create_having_owner(user)
    self.create(title: user.dispname + "のアルバム", owner_id: user.id, user_id: user.id)
  end

  # サムネイルが設定されていないものは、サムネイルがランダムで選択されるようにする
  def self.set_thumb(albums)
    albums.map do |album|
      if album.thumb_id.blank?
        photo = album.photos.sample
        album.thumb_id = photo.id if photo.present?
      end
      album
    end
  end

  def thumb_path
    self.thumb.present? ? self.thumb.image(:thumb) : NO_IMAGE_PATH
  end

  # photos, moviesをincludesしてから使う
  def media_count
    self.photos.size + self.movies.size
  end
end
