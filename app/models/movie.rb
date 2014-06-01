class Movie < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  belongs_to :mutter
  has_many :comments, as: :parent
  has_many :nices, :as => :asset

  # todo
  has_many :movie_comments
  has_many :update_histories, :as => :content, :dependent => :destroy

  default_scope {order('id DESC')}

  attr_accessor :ffmp_obj, :is_update_thumb

  validates :title, presence: true

  # [knowhow] フィールド名は「movie」だけど、エラー変数に設定されるのは「movie_file_name」になるので、こちらの方にメッセージを設定しておく
  validates :movie, presence: true
  validates :movie_file_name, presence: {message: "動画ファイルを選択してください"}

  TYPE_NORMAL = 0
  TYPE_MODIFY = 1

  content_name = "movie"
  has_attached_file :movie,
    :url => "/upload/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:id/:style/:basename.:extension"

  # "vide"で始まるContentType
  validates_attachment_content_type :movie, :content_type => /\Avide.?\/.*\Z/

  has_attached_file :thumb,
    :styles => {
      :thumb => "250x250>",
      :large => "600x600>"
    },
    :convert_options => { :thumb => ['-quality 80', '-strip']}, #50じゃノイズきつい
    :url => "/upload/#{content_name}/:id/thumb/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:id/thumb/:style/:basename.:extension"

  validates_attachment_content_type :thumb, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", "application/octet-stream"]

  # todo 
  # before_saveにして色々やんなきゃなのかなぁ
  # def encode
    # return false unless movie.valid?
    # EncodeWorker.perform_async self.id
  # end

  def encode
    generate_thumb
    encoded_path = "#{Rails.root}/public/upload/movie/#{id}/original/encoded.mp4"
    ffmp.transcode("#{encoded_path}", "-vcodec libx264 -b 500k -acodec libfaac -ab 96k")
    original_name = self.movie_file_name
    update_attributes(is_ready: true, movie: File.open("#{encoded_path}", "r"), original_movie_file_name: original_name)
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
  def generate_thumb
    if self.thumb.blank?
      tmp_path = "#{Rails.root}/public/upload/movie/#{id}/tmp/thumb.jpg"
      system("mkdir -p #{Pathname.new(tmp_path).dirname.to_s}")
      self.ffmp.screenshot(tmp_path)
      update(thumb: File.open(tmp_path, "r"))
    end
  end

end
