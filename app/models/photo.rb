# == Schema Information
#
# Table name: photos
#
#  id                 :integer          not null, primary key
#  deleted_at         :datetime
#  description        :text(65535)
#  exif_at            :datetime
#  image_content_type :string(255)
#  image_file_name    :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  last_comment_at    :datetime
#  title              :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  album_id           :integer
#  comment_id         :integer
#  mutter_id          :integer
#  user_id            :integer
#

class Photo < ApplicationRecord
  include MutterComment

  acts_as_paranoid

  belongs_to :album
  belongs_to :user
  belongs_to :mutter, optional: true
  has_many :nices, :as => :asset
  has_many :update_histories, :as => :content, :dependent => :destroy

  scope :includes_all, lambda {includes({user: :user_ext}, {nices: {user: :user_ext}})}
  scope :id_desc, -> { order('id DESC') }

  has_one_attached :image

  # memo なんだろう「image/pjpeg」って。。Mutterにて投稿されていた
  CONTENT_TYPE = ["image/jpg", "image/jpeg", "image/png", "image/gif", "application/octet-stream", "image/pjpeg", "image/bmp"].freeze
  EXTS = ["jpg", "jpeg", "png", "gif", "bmp"]

  IMAGE_VARIANTS = {
    thumb: { resize_to_limit: [250, 250] },
    large: { resize_to_limit: [800, 800] }
  }.freeze

  validate :image_content_type

  def image_variant(name)
    return nil unless image.attached?
    option = IMAGE_VARIANTS[name]
    return nil if option.blank?
    image.variant(**option)
  end

  def image_content_type
    return unless image.attached?
    return if CONTENT_TYPE.include?(image.content_type)

    errors.add(:image, "の形式が不正です")
  end


  #全写真からただランダムに抽出する
  def self.rnd_photos
    return [] if Album.last.blank?
    return Album.last.photos if Rails.env.development?

    photos = self.includes(:album).order("RAND()").limit(15).map{|photo| photo if photo.album.present?}
#sakikazu 上でalbumが実際に存在しなかったら、if文のせいで(？)、nilが入ってしまう。なので削除しておく
# ★これってどうしようかな。アルバムない写真を全削除？上のはもっと良いやり方ある？これは注意すべき事象なので、解析してメモっておきたい
    photos.delete_if{|p| p == nil}
    photos
  end

  require 'exifr/jpeg'
  # ファイルパスが必要なので、コールバック内ではなく、明示的に呼び出して処理するようにした
  def self.set_exif_at(filepath)
    #memo 「date_time」だと、写真の更新日付になってしまうことがあった。「exif.date_time_digitized」で取得すること
    begin
      exif_data = EXIFR::JPEG.new(filepath)
    rescue => e
      # EXIFR::のExceptionは、exifデータがない画像などの場合なので無視する
      raise e unless e.class.name.start_with?('EXIFR::')
    end

    if exif_data.present?
      ((exif_data.exif && exif_data.exif.date_time_digitized) || exif_data.date_time) rescue nil
    else
      nil
    end
  end

  def self.valid_ext?(filename)
    ext = File.extname(filename).gsub(".", "").downcase
    EXTS.include?(ext)
  end
end
