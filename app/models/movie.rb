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
  include MutterComment

  acts_as_paranoid

  belongs_to :album
  belongs_to :user
  belongs_to :mutter, optional: true
  has_many :nices, :as => :asset
  has_many :update_histories, :as => :content, :dependent => :destroy

  # default_scope {order('movies.id DESC')}
  scope :includes_all, lambda {includes({user: :user_ext}, {nices: {user: :user_ext}})}
  scope :id_desc, -> { order('id DESC') }

  attr_accessor :ffmp_obj, :is_update_thumb

  has_one_attached :movie
  has_one_attached :thumb

  validates :title, presence: true

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

  THUMB_VARIANTS = {
    thumb: { resize_to_limit: [250, 250] },
    large: { resize_to_limit: [600, 600] }
  }.freeze

  validate :movie_presence
  validate :movie_content_type
  validate :movie_size
  validate :thumb_content_type

  def thumb_variant(name)
    return nil unless thumb.attached?
    option = THUMB_VARIANTS[name]
    return nil if option.blank?
    thumb.variant(**option)
  end

  def movie_presence
    return if movie.attached?

    errors.add(:movie, 'ファイルを選択してください。')
  end

  def movie_content_type
    return unless movie.attached?
    return if movie.content_type&.match?(CONTENT_TYPE)

    errors.add(:movie, 'の形式が不正です')
  end

  def movie_size
    return unless movie.attached?
    return if movie.blob.byte_size <= Settings.MAX_MOVIE_MEGABYTES.megabytes

    errors.add(:movie, 'のサイズが大きすぎます')
  end

  def thumb_content_type
    return unless thumb.attached?
    return if Photo::CONTENT_TYPE.include?(thumb.content_type)

    errors.add(:thumb, 'の形式が不正です')
  end

  # todo 
  # before_saveにして色々やんなきゃなのかなぁ
  # def encode
    # return false unless movie.valid?
    # EncodeWorker.perform_async self.id
  # end

  def workered_encode
    # 「エンコード中」状態にしておく
    self.update(is_ready: false)
    if Rails.env.production?
      EncodeWorker.perform_async self.id
    else
      self.encode
      self.save_with_available_movie
    end
  end

  # Classで分けたいな todo
  def encode
    with_ffmpeg do |ffmp|
      generate_thumb(ffmp, ffmp.rotation.to_i)
      # p "rotation: #{ffmp.rotation}"
      # transpose = "transpose=#{ROTATION[ffmp.rotation.to_s].to_i}" if ffmp.rotation.present?
      max_video_bitrate = 1000
      vbitrate = ffmp.bitrate < max_video_bitrate ? ffmp.bitrate : max_video_bitrate

      # note: about profile -> http://qiita.com/yuya_presto/items/9fed29296dbdc7fd1d5d
      profile_option = %w(-profile:v baseline -level:v 3.1)
      # note: 既にエンコードされた「encoded.mp4」を再エンコードする場合、同じファイルをエンコード、出力するとおかしくなるので、テンポラリファイルにエンコード出力する
      encoding_file = Tempfile.new(["movie_encoding_#{id}_", ".mp4"], Rails.root.join("tmp"))
      transcode_options = %W(-r 30 -vcodec libx264 -b:v #{vbitrate}k -acodec aac -strict experimental -b:a 96k)
      size = calc_size(ffmp)
      transcode_options += %W(-s #{size}) if size.present?
      # NOTE: rotation:90の動画をエンコードした際、縦動画が横動画として表示されてしまった
      # Chromeだとrotationを意識した回転をやってくれるのでとりあえず不要
      # 一番問題ないのは回転させた上でrotation情報を削除することなはず。ref: https://qiita.com/naga3/items/639da87ad56c67549eee
      # あと、heightとwidthの長辺を指定のサイズにしたとしても、transcodeで回転させると逆になるかもなので注意。例：長辺720にして、h:720, w:450にしたのに、回転されることでh:720, w:1280みたいな。詳細は未調査
      # transcode_options += %W(-vf #{transpose}) if transpose.present?
      transcode_options += profile_option
      begin
        ffmp.transcode(encoding_file.path, transcode_options)
      rescue => e
        ExceptionNotifier.notify_exception(e)
      end
      save_with_available_movie(encoding_file.path)
    ensure
      encoding_file.close! if encoding_file
    end
  end

  # ffmpegでサムネイルを作成したいが、Herokuだとインストールがめんどくさそうでやっぱやめとこ
  def save_with_available_movie(movie_path = nil)
    self.is_ready = true
    self.original_movie_file_name ||= movie.filename.to_s if movie.attached?
    if movie_path.present?
      File.open(movie_path, "rb") do |io|
        movie.attach(io: io, filename: File.basename(movie_path), content_type: "video/mp4")
      end
    end
    self.save
    p self.errors.full_messages
  end

  def is_ready?
    is_ready == 1
  end

  def ffmpeg_valid?(file: nil)
    if file&.respond_to?(:path)
      return FFMPEG::Movie.new(file.path).valid?
    end

    with_movie_file do |path|
      return FFMPEG::Movie.new(path).valid?
    end
    false
  end

  # サムネイルがフォームから指定されていないときは動画から生成する
  # [memo] saveの前に実行する時は、サムネイルが指定されたときはスルーする判別の必要がある
  def generate_thumb(ffmp, rotate)
    # todo ここを無効にすることで、フォームでサムネイル指定されても動画から生成して上書きするようになっている。テーブルにフラグ追加して、動画から生成するか否かを保存しておき、そこで判定する必要がある
    # if self.thumb.blank?
      tmp_file = Tempfile.new(["movie_thumb_#{id}_", ".jpg"], Rails.root.join("tmp"))
      ffmp.screenshot(tmp_file.path)
      if rotate > 0
        image = Magick::ImageList.new(tmp_file.path)
        image.rotate(rotate).write(tmp_file.path)
      end
      File.open(tmp_file.path, "rb") do |io|
        thumb.attach(io: io, filename: "thumb.jpg", content_type: "image/jpeg")
      end
    # end
  ensure
    tmp_file.close! if tmp_file
  end

  # memo content_typeではなく拡張子で判定した理由は、動画も写真とも「application/octet-stream」でアップされることがあるため。Ajaxの時だけかも。
  # そのアップ時にうまくやる方法がありそうだけど
  def self.valid_ext?(filename)
    ext = File.extname(filename).gsub(".", "").downcase
    EXTS.include?(ext)
  end

  def with_movie_file
    return nil unless movie.attached?

    begin
      movie.blob.open do |file|
        yield file.path
      end
    rescue ActiveStorage::FileNotFoundError
      nil
    end
  end

  def with_ffmpeg
    with_movie_file do |path|
      yield FFMPEG::Movie.new(path)
    end
  end

  private

  def calc_size(ffmp)
    size = nil
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
        height = (ffmp.height * ratio).to_i
      end
      size = "#{divisible_size(width)}x#{divisible_size(height)}"
      p "computed size: #{size}"
    end
    size
  end

  # NOTE: ffmpeg encode時にheightかwidthが2で割り切れないときは「[height|width] not divisible by 2」というエラーが出るので偶数にする
  def divisible_size size
    return (size % 2 == 1) ? size + 1 : size
  end
end
