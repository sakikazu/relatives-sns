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
  include Utility

  acts_as_paranoid

  belongs_to :album
  belongs_to :user
  belongs_to :mutter, optional: true
  has_many :nices, :as => :asset
  has_many :update_histories, :as => :content, :dependent => :destroy

  scope :includes_all, lambda {includes({user: :user_ext}, {nices: {user: :user_ext}})}


  # memo なんだろう「image/pjpeg」って。。Mutterにて投稿されていた
  CONTENT_TYPE = ["image/jpg", "image/jpeg", "image/png", "image/gif", "application/octet-stream", "image/pjpeg", "image/bmp"]
  EXTS = ["jpg", "jpeg", "png", "gif", "bmp"]

  content_name = "album"
  has_attached_file :image,
    :styles => {
      :thumb => "250x250>",
      :large => "800x800>"
    },
    :convert_options => { :thumb => ['-quality 70', '-strip']}, #50じゃノイズきつい
    :url => "/upload/#{content_name}/:album/:id/:style/:hash.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:album/:id/:style/:hash.:extension",
    default_url: "/assets/missing.gif"

  validates_attachment_content_type :image, content_type: CONTENT_TYPE


  #全写真からただランダムに抽出する
  def self.rnd_photos
    return Album.last.photos if Rails.env.development?

    photos = self.includes(:album).order("RAND()").limit(15).map{|photo| photo if photo.album.present?}
#sakikazu 上でalbumが実際に存在しなかったら、if文のせいで(？)、nilが入ってしまう。なので削除しておく
# ★これってどうしようかな。アルバムない写真を全削除？上のはもっと良いやり方ある？これは注意すべき事象なので、解析してメモっておきたい
    photos.delete_if{|p| p == nil}
    photos
  end

  # ファイルパスが必要なので、コールバック内ではなく、明示的に呼び出して処理するようにした
  def self.set_exif_at(filepath)
    #memo 「date_time」だと、写真の更新日付になってしまうことがあった。「exif.date_time_digitized」で取得すること
    #memo 追記 EXIFがない画像への対処を入れた
    e_data = EXIFR::JPEG.new(filepath) rescue err_flg = true
    exif_at = nil
    if err_flg.blank?
      exif_at = ((e_data.exif && e_data.exif.date_time_digitized) || e_data.date_time) rescue nil
    end
    exif_at
  end

  def self.valid_ext?(filename)
    ext = File.extname(filename).gsub(".", "").downcase
    EXTS.include?(ext)
  end
end
