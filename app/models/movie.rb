class Movie < ActiveRecord::Base
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

    max_video_wid_hei = 640
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
      size = "-s #{width}x#{height}"
      p "computed size: #{size}"
    end

    max_video_bitrate = 500
    vbitrate = ffmp.bitrate < max_video_bitrate ? ffmp.bitrate : max_video_bitrate

    ffmp.transcode("#{encoded_path}", "-r 30 -vcodec libx264 -b:v #{vbitrate}k -acodec libfaac -b:a 96k #{size} #{transpose}")
    self.is_ready = true
    self.movie = File.open("#{encoded_path}", "r")
    self.original_movie_file_name = self.movie_file_name if self.original_movie_file_name.blank?
    self.save
    p self.errors.full_messages
  end

  def is_ready?
    is_ready == 1
  end

  def uploaded_full_path
    "/upload/movie/#{id}/original/#{movie_file_name}"
  end

  def ffmp
    @ffmp_obj ||= FFMPEG::Movie.new("#{Rails.root}/public/upload/movie/#{id}/original/#{self.movie_file_name}")
  end

  # サムネイルがフォームから指定されていないときは動画から生成する
  # [memo] saveの前に実行する時は、サムネイルが指定されたときはスルーする判別の必要がある
  def generate_thumb(rotate)
    if self.thumb.blank?
      tmp_path = "#{Rails.root}/public/upload/movie/#{id}/tmp/thumb.jpg"
      system("mkdir -p #{Pathname.new(tmp_path).dirname.to_s}")
      self.ffmp.screenshot(tmp_path)
      if rotate > 0
        image = Magick::ImageList.new(tmp_path)
        image.rotate(rotate).write(tmp_path)
      end
      thumb = File.open(tmp_path, "r")
      update(thumb: thumb)
    end
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

end
