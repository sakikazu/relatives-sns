# == Schema Information
#
# Table name: movies
#
#  id                       :integer          not null, primary key
#  deleted_at               :datetime
#  description              :text(65535)
#  is_ready                 :integer          default(0)
#  movie_content_type       :string(255)
#  movie_file_name          :string(255)
#  movie_file_size          :integer
#  movie_type               :integer
#  movie_updated_at         :datetime
#  original_movie_file_name :string(255)
#  thumb_content_type       :string(255)
#  thumb_file_name          :string(255)
#  thumb_file_size          :integer
#  thumb_updated_at         :datetime
#  title                    :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  album_id                 :integer
#  mutter_id                :integer
#  user_id                  :integer
#

class Movie < ApplicationRecord
  include Utility

  acts_as_paranoid

  belongs_to :album
  belongs_to :user
  belongs_to :mutter
  has_many :nices, :as => :asset
  has_many :update_histories, :as => :content, :dependent => :destroy

  # default_scope {order('movies.id DESC')}
  scope :includes_all, lambda {includes({user: :user_ext}, {nices: {user: :user_ext}})}

  attr_accessor :ffmp_obj, :is_update_thumb

  validates :title, presence: true


  # [knowhow] フィールド名は「movie」だけど、エラー変数に設定されるのは「movie_file_name」になるので、こちらの方にメッセージを設定しておく
  validates :movie, presence: true
  validates :movie_file_name, presence: {message: "動画ファイルを選択してください"}

  TYPE_NORMAL = 0
  TYPE_MODIFY = 1

  CONTENT_TYPE = /\Avide.?\/.*\Z|application\/octet-stream/
  EXTS = ["mp4", "wmv", "avi", "mpeg", "mpg", "mkv", "m4v", "mov", "3gp"]

  # ffmpeg rotation values
  # 0 = 90CounterCLockwise and Vertical Flip (default)
  # 1 = 90Clockwise
  # 2 = 90CounterClockwise
  # 3 = 90Clockwise and Vertical Flip
  ROTATION = {"90" => 1, "180" => 2, "270" => 3}

  content_name = "movie"
  has_attached_file :movie,
    :url => "/upload/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:id/:style/:basename.:extension"

  # "vide"で始まるContentType
  validates_attachment_content_type :movie, content_type: CONTENT_TYPE
  validates_attachment_size :movie, less_than: Settings.MAX_MOVIE_MEGABYTES.megabytes

  has_attached_file :thumb,
    :styles => {
      :thumb => "250x250>",
      :large => "600x600>"
    },
    :convert_options => { :thumb => ['-quality 80', '-strip']}, #50じゃノイズきつい
    :url => "/upload/#{content_name}/:id/thumb/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:id/thumb/:style/:basename.:extension",
    default_url: "/images/missing.gif"

  validates_attachment_content_type :thumb, :content_type => Photo::CONTENT_TYPE

  # todo 
  # before_saveにして色々やんなきゃなのかなぁ
  # def encode
    # return false unless movie.valid?
    # EncodeWorker.perform_async self.id
  # end

  # Classで分けたいな todo
  def encode
    generate_thumb(ffmp.rotation.to_i)
    encoded_path = "#{Rails.root}/public/upload/movie/#{id}/original/encoded.mp4"
    # p "rotation: #{ffmp.rotation}"
    transpose = "-vf transpose=#{ROTATION[ffmp.rotation.to_s].to_i}" if ffmp.rotation.present?

    max_video_wid_hei = 720
    p "original size: width: #{ffmp.width} / height: #{ffmp.height}"
    if ffmp.width.present? and ffmp.height.present? and (ffmp.width > max_video_wid_hei || ffmp.height > max_video_wid_hei)
      if ffmp.height > ffmp.width
        ratio = max_video_wid_hei.to_f / ffmp.height
        height = max_video_wid_hei
        width = (ffmp.width * ratio).to_i
      else
        ratio = max_video_wid_hei.to_f / ffmp.width
        width = max_video_wid_hei 
        height = fix_height((ffmp.height * ratio).to_i)
      end
      size = "-s #{width}x#{height}"
      p "computed size: #{size}"
    end

    max_video_bitrate = 1000
    vbitrate = ffmp.bitrate < max_video_bitrate ? ffmp.bitrate : max_video_bitrate

    # note: http://qiita.com/yuya_presto/items/9fed29296dbdc7fd1d5d
    profile_option = "-profile:v baseline -level:v 3.1"
    # note: 既にエンコードされた「encoded.mp4」を再エンコードする場合、同じファイルをエンコード、出力するとおかしくなるので、テンポラリファイルにエンコード出力する
    encoding_path = "encoding_#{Time.now.to_i}.mp4"
    ffmp.transcode(encoding_path, "-r 30 -vcodec libx264 -b:v #{vbitrate}k -acodec libfaac -b:a 96k #{size} #{transpose} #{profile_option}")
    FileUtils.mv(encoding_path, encoded_path)
    self.is_ready = true
    self.movie = File.open("#{encoded_path}", "r")
    self.original_movie_file_name = self.movie_file_name if self.original_movie_file_name.blank?
    self.save
    p self.errors.full_messages
  end

  # ffmpegでサムネイルを作成したいが、Herokuだとインストールがめんどくさそうでやっぱやめとこ
  def without_encode
    self.is_ready = true
    self.movie = File.open("#{original_path}", "r")
    self.original_movie_file_name = self.movie_file_name if self.original_movie_file_name.blank?
    self.save
  end

  def is_ready?
    is_ready == 1
  end

  def uploaded_full_path
    "/upload/movie/#{id}/original/#{movie_file_name}"
  end

  def ffmp
    @ffmp_obj ||= FFMPEG::Movie.new(original_path)
  end

  def original_path
    "#{Rails.root}/public/upload/movie/#{self.id}/original/#{self.movie_file_name}"
  end

  # サムネイルがフォームから指定されていないときは動画から生成する
  # [memo] saveの前に実行する時は、サムネイルが指定されたときはスルーする判別の必要がある
  def generate_thumb(rotate)
    # todo ここを無効にすることで、フォームでサムネイル指定されても動画から生成して上書きするようになっている。テーブルにフラグ追加して、動画から生成するか否かを保存しておき、そこで判定する必要がある
    # if self.thumb.blank?
      tmp_path = "#{Rails.root}/public/upload/movie/#{id}/tmp/thumb.jpg"
      system("mkdir -p #{Pathname.new(tmp_path).dirname.to_s}")
      self.ffmp.screenshot(tmp_path)
      if rotate > 0
        image = Magick::ImageList.new(tmp_path)
        image.rotate(rotate).write(tmp_path)
      end
      thumb = File.open(tmp_path, "r")
      update(thumb: thumb)
    # end
  end

  def has_parent_mutter?
    self.mutter.present?
  end

  def comments
    return [] unless self.has_parent_mutter?
    self.mutter.children.includes({user: :user_ext}).reorder("id ASC")
  end

  # memo content_typeではなく拡張子で判定した理由は、動画も写真とも「application/octet-stream」でアップされることがあるため。Ajaxの時だけかも。
  # そのアップ時にうまくやる方法がありそうだけど
  def self.valid_ext?(filename)
    ext = File.extname(filename).gsub(".", "").downcase
    EXTS.include?(ext)
  end

  def thumb_path
    self.thumb? ? self.thumb(:large) : "/assets/movie_thumb.jpg"
  end

  private

  # note: mp4動画をリサイズするときにheightが2で割り切れないときは「height not divisible by 2」というエラーが出るので、偶数にする
  def fix_height height
    return (height % 2 == 1) ? height + 1 : height
  end
end
