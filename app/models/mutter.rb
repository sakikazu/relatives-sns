# == Schema Information
#
# Table name: mutters
#
#  id                    :integer          not null, primary key
#  content               :text(65535)
#  deleted_at            :datetime
#  for_sort_at           :datetime
#  image_content_type    :string(255)
#  image_file_name       :string(255)
#  image_file_size       :integer
#  image_updated_at      :datetime
#  invisible_in_timeline :boolean          default(FALSE)
#  leave_me              :boolean          default(FALSE)
#  ua                    :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  celebration_id        :integer
#  reply_id              :integer
#  user_id               :integer
#

class Mutter < ApplicationRecord
  acts_as_paranoid

  # kaminari
  paginates_per 7
  PAGINATES_PER_FOR_ALL = 15

  belongs_to :user
  belongs_to :celebration, optional: true
  belongs_to :parent, class_name: "Mutter", foreign_key: "reply_id", optional: true
  has_many :children, class_name: "Mutter", foreign_key: "reply_id"
  has_many :nices, as: :asset

  has_one :movie, dependent: :destroy
  has_one :photo, dependent: :destroy

  # 2014/06/05、とりあえず、つぶやきにひもづけるのはphotoとmovieのみ
  # has_one :album
  # has_one :blog
  # has_one :board
  # has_one :history

  before_save :trans_space
  before_save :fill_for_sort_at
  after_save :save_related_media
  after_create :update_sort_at
  after_create_commit :broadcast_mutter_channel
  # NOTE: destroy時にacts_as_paranoidがafter_destroyをトリガーする（実際はupdate）
  after_destroy :broadcast_mutter_channel_on_destroy

  # validates_presence_of :content

  attr_accessor :search_word, :action_flg, :year, :month, :image, :is_save_related_media

  VISIBLE_INITIAL_COMMENTS = 3

  # [memo]こうやってそれぞれにuser、user_extを指定するようにすると、最初のリクエスト時にはやっぱ時間短縮されてる。
  # 二度目のリクエストではキャッシュされるらしく、それぞれに指定しなかった時と同じ速度になる。
  # 2014/06/05、とりあえず、つぶやきにひもづけるのはphotoとmovieのみ
  scope :includes_all, lambda { includes(:photo, :movie, {:user => :user_ext}, {nices: {user: :user_ext}}, {children: [{user: :user_ext}, :photo, :movie, {nices: {user: :user_ext}}]}) }
  scope :only_parents, lambda { where("mutters.reply_id IS NULL") } #「parents」が自動で定義されていたので。返り値がArrayだったので使えなかった
  # つぶやき以外の機能のための空の親用Mutterを除外する
  scope :without_wrapper, lambda { where(invisible_in_timeline: false) }
  scope :id_desc, lambda { order("mutters.id DESC") }
  scope :id_asc, lambda { order("mutters.id ASC") }
  scope :updated_order, lambda { order("mutters.for_sort_at DESC") }


  def trans_space
    #auto_linkでURLの後に全角スペースが入るとリンクが延長されてしまうため、半角スペースに変換
    self.content.gsub!("　", " ") if self.content.present?
  end

  def fill_for_sort_at
    if self.for_sort_at.blank?
      self.for_sort_at = Time.now
    end
  end

  def save_related_media
    return if self.is_save_related_media.present? or self.image.blank?
    self.is_save_related_media = true
    self._save_related_media
  end

  def _save_related_media
    current_user = self.user
    Album.create_having_owner(current_user) if current_user.my_album.blank?
    current_user.reload

    truncated_title = self.content.size > 20 ? self.content[0..19] + "..." : self.content
    description_for_media = self.content + "\n\n" + "(つぶやきから投稿)"
    saved_content = nil
    if Photo::valid_ext?(self.image.original_filename)
      photo = Photo.new(title: truncated_title, mutter_id: self.id, user_id: self.user_id, album_id: current_user.my_album.id, description: description_for_media, created_at: self.created_at)
      photo.exif_at = Photo::set_exif_at(self.image.path)
      photo.image = self.image
      photo.save
      saved_content = photo
    elsif Movie::valid_ext?(self.image.original_filename)
      movie = Movie.new(title: truncated_title, mutter_id: self.id, user_id: self.user_id, album_id: current_user.my_album.id, description: description_for_media, created_at: self.created_at)
      movie.movie = self.image
      if movie.save and movie.ffmp.valid?
        begin
          EncodeWorker.perform_async movie.id
        rescue Redis::CannotConnectError => e
          p "Redisが動いてないのでエンコードなしで保存します"
          movie.save_with_available_movie
        end
      else
        # p movie.errors.full_messages
      end
      saved_content = movie
    end
    saved_content
  end


  # ソート用の日時カラムを更新。レスされた親のも更新する。
  def update_sort_at
    # memo 2014/06/12、Mutter.create時にfor_sort_atも設定するようにしたので、ここでは、子Mutterの場合だけ、その親のものを更新するようにした
    # self.update(for_sort_at: Time.now)
    if self.parent.present? and !self.parent.invisible?
      self.parent.update(for_sort_at: Time.now)
    end
  end

  def view_content
    # [後方不一致の正規表現]
    # 顔文字対策(ex. 「(・ω<)ああ」と書くと、sanitizeによって「<」以降が消えてしまうので、タグとしての「<」でなければ、「＜」に置換する
    # この正規表現だと、(・ω<)のあとにタグ<iframe>とか入れられたら顔文字の置換はされないけどな
    content = self.content&.gsub(/<(?!.*>)/, "＜")

    if self.celebration.present?
      "<span class='badge badge-warning'>【祝】 #{self.celebration.user.try(:dispname)}さんへ</span> #{content}"
    else
      content
    end
  end

   #
   # 更新されたMutterデータを取得する（つぶやき自動表示更新用）
   #
   # @param モデルでCookieを使用するためインスタンスを渡してやる
   # @return 更新されていた場合はデータを返す
   #
   def self.updated_datas(cookies)
     return if self.count == 0

     last_id = self.uncached {
       # [memo] self.unscoped.last.id だと、uncachedしているのに再ロードされず。クエリーキャッシュは使われてないんだけど、別の機構で保持されてる感じ
       # [memo] ここではunscopedをしないと、for_sort_atでソートされてしまうし、unscopedをした場合はid_descまでつけてやらないと再読み込みしてくれない
       last_id = self.unscoped.id_desc.first.id
     }

     if cookies[:update_disp_id].blank?
       cookies[:update_disp_id] = last_id
       return false
     end

     prev_id = cookies[:update_disp_id].to_i
     if last_id > prev_id
       cookies[:update_disp_id] = last_id
       return self.includes_all.only_parents.without_wrapper.where(leave_me: false)
     else
       return false
     end
   end

   def parent?
     self.reply_id.blank?
   end

   def child?
     self.reply_id.present?
   end

   def invisible?
     self.invisible_in_timeline.present?
   end

   def self.create_with_invisible(current_user_id)
      self.create(user_id: current_user_id, invisible_in_timeline: true)
   end

   # TODO: controllerのparamsにマージじゃなく、Mutterオブジェクトのattributesにマージすべき
   # そしてstrong parametersから該当要素は削除。修正が面倒そうなのでとりあえず放置
   def self.extra_params(current_user, request = nil, celebration_id = nil)
     params = {}
     params[:user_id] = current_user.id
     params[:ua] = request.env["HTTP_USER_AGENT"] if request.present?
     params[:celebration_id] = celebration_id if celebration_id.present?
     params[:for_sort_at] = Time.now
     return params
   end

  def user_image_path
    user.present? ? user.user_ext.image(:small) : NO_IMAGE_PATH
  end

  def self.count_unread_leave_me_mutters(user, shown_leave_me)
    if shown_leave_me.present?
      user.save_extension(UserExtension::LAST_READ_LEAVE_ME_AT, Time.now())
      return 0
    else
      ext = user.find_extension(UserExtension::LAST_READ_LEAVE_ME_AT)
      last_read_at = ext.present? ? ext[:value] : Time.parse("2000/1/1")
      return self.without_wrapper.where(leave_me: true).where.not(user_id: user.id).where("created_at > ?", last_read_at).count
    end
  end

  private

  def broadcast_mutter_channel
    return if self.invisible? || self.parent&.invisible?
    ActionCable.server.broadcast 'mutter_channel', deleted: false, mutter_id: self.id, mutter_html: render_mutter, parent_mutter_id: self.reply_id
  end

  def broadcast_mutter_channel_on_destroy
    ActionCable.server.broadcast 'mutter_channel', deleted: true, mutter_id: self.id
  end

  def render_mutter
    if self.parent?
      ApplicationController.renderer.render(partial: 'mutters/mutter_with_comments', locals: { mutter_with_comments: self })
    else
      ApplicationController.renderer.render(partial: 'mutters/mutter', locals: { mutter: self })
    end
  end
end
