class Mutter < ActiveRecord::Base
  acts_as_paranoid

  # kaminari
  paginates_per 7

  belongs_to :user
  belongs_to :celebration
  belongs_to :parent, class_name: "Mutter", foreign_key: "reply_id"
  has_many :children, class_name: "Mutter", foreign_key: "reply_id"
  has_many :nices, :as => :asset

  has_one :movie
  has_one :photo

  # 2014/06/05、とりあえず、つぶやきにひもづけるのはphotoとmovieのみ
  # has_one :album
  # has_one :blog
  # has_one :board
  # has_one :history

  before_save :trans_space
  after_save :save_related_media
  after_create :update_sort_at
  # validates_presence_of :content
  attr_accessor :search_word, :action_flg, :year, :month, :image, :is_save_related_media

  @@imap = nil

  # content_name = "mutter"
  # has_attached_file :image,
    # :styles => {
      # :thumb => "150x150>",
      # :large => "800x800>"
    # },
    # :convert_options => { :thumb => ['-quality 70', '-strip']}, #50じゃノイズきつい
    # :url => "/upload/#{content_name}/:id/:style/:basename.:extension",
    # :path => ":rails_root/public/upload/#{content_name}/:id/:style/:basename.:extension"

  # validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", "application/octet-stream"]

  scope :user_is, lambda {|n| n.present? ? where(:user_id => n).id_desc : id_desc}

  # [memo]こうやってそれぞれにuser、user_extを指定するようにすると、最初のリクエスト時にはやっぱ時間短縮されてる。
  # 二度目のリクエストではキャッシュされるらしく、それぞれに指定しなかった時と同じ速度になる。
  # 2014/06/05、とりあえず、つぶやきにひもづけるのはphotoとmovieのみ
  # scope :includes_all, lambda { includes(:photo, :movie, :album, :blog, :board, {:user => :user_ext}, {:nices => {:user => :user_ext}}, {children: [:photo, :movie, :album, :blog, :board, {nices: {user: :user_ext}}]}) }
  scope :includes_all, lambda { includes(:photo, :movie, {:user => :user_ext}, {nices: {user: :user_ext}}, {children: [{user: :user_ext}, :photo, :movie, {nices: {user: :user_ext}}]}) }

  scope :parents_mod, lambda { where("mutters.reply_id IS NULL").where(invisible_in_timeline: false) } #「parents」が自動で定義されていたので。返り値がArrayだったので使えなかった
  scope :id_desc, lambda { order("mutters.id DESC") }
  scope :id_asc, lambda { order("mutters.id ASC") }

  default_scope {order("for_sort_at DESC")}


  def trans_space
    #auto_linkでURLの後に全角スペースが入るとリンクが延長されてしまうため、半角スペースに変換
    self.content.gsub!("　", " ") if self.content.present?
  end

  def save_related_media
    return if self.is_save_related_media.present? or self.image.blank?

    self.is_save_related_media = true
    photo_type = ["image/jpg", "image/jpeg", "image/png", "image/gif", "application/octet-stream"]
    movie_type = /\Avide.?\/.*\Z/

    # todo メソッド切り出し
    current_user = self.user
    Album.create_having_owner(current_user) if current_user.my_album.blank?
    current_user.reload

    truncated_title = self.content.size > 20 ? self.content[0..19] + "..." : self.content
    description_for_media = self.content + "\n\n" + "(つぶやきから投稿)"
    if photo_type.include?(self.image.content_type)
      photo = Photo.new(title: truncated_title, mutter_id: self.id, user_id: self.user_id, album_id: current_user.my_album.id, description: description_for_media)
      photo.image = self.image
      photo.save
    elsif self.image.content_type =~ movie_type
      movie = Movie.new(title: truncated_title, mutter_id: self.id, user_id: self.user_id, album_id: current_user.my_album.id, description: description_for_media)
      movie.movie = self.image
      if movie.save and movie.ffmp.valid?
        EncodeWorker.perform_async movie.id
      else
        # p movie.errors.full_messages
      end
    end
  end

  # ソート用の日時カラムを更新。レスされた親のも更新する。
  def update_sort_at
    # memo 2014/06/12、Mutter.create時にfor_sort_atも設定するようにしたので、ここでは、子Mutterの場合だけ、その親のものを更新するようにした
    # self.update_attributes(for_sort_at: Time.now)
    if self.parent.present?
      self.parent.update_attributes(for_sort_at: Time.now)
    end
  end

  def view_content
    # [後方不一致の正規表現]
    # 顔文字対策(ex. 「(・ω<)ああ」と書くと、sanitizeによって「<」以降が消えてしまうので、タグとしての「<」でなければ、「＜」に置換する
    # この正規表現だと、(・ω<)のあとにタグ<iframe>とか入れられたら顔文字の置換はされないけどな
    content = self.content.gsub(/<(?!.*>)/, "＜")

    if self.celebration.present?
      "<span class='badge badge-warning'>【祝】 #{self.celebration.user.try(:dispname)}さんへ</span> #{content}"
    else
      content
    end
  end

  # -------------------------------------
  # メールからつぶやき、画像を取得する
  # ※指定したラベルにある、未読のメールで、件名に特定の文字列が入っており、ファイルが添付されているメールが処理対象
  #
  # ref: ruby-gmailを使ってRubyからGmailのメールを受信して本文を取得 - Shoken OpenSource Society http://shoken.hatenablog.com/entry/20120401/p1
  # -------------------------------------
  require 'gmail'
  def self.create_from_mail
    config = YAML.load(File.read(File.join(Rails.root, 'config', 'gmail.yml')))
    gmail = Gmail.new(config['username'], config['password'])
    mails =  gmail.mailbox(config['gmail_label']).emails(:unread).each do |mail| #emailsの引数には:all,:read,:unreadがある
      self.create_from_mail2(mail)
    end
    gmail.disconnect
  end

  # ファイルが添付されてないとMutterを作成しない
  def self.create_from_mail2(email)
    # check -- タイトルは正しいか、user_idは取得できたか、ファイルが添付されているか
    sub = email.subject
    title_check = [sub.index("[a-dan-hp]").present?, sub.index("[user_id]").present?].all?
    u = sub.split("[user_id]")[1]
    u_check = u.present? && u =~ /\d/
    return if [title_check, u_check, email.attachments.present?].any?{|x| x.blank?}
    p '### mail has attachments & title check ok -------------'

    user_id = u.to_i
    content = self.get_content(email)

    # todo 1メール中の複数ファイルって対応できるのかな？
    # todo 現在、まずはファイルに保存してそれを読み込んでPaperclipに登録しているが、もっと簡易化できると思うんだけど
    #メールの判定などのコード(省略)  ←って何をすべきなんだろう？
    email.attachments.each do |attach|
      # p attach.content_type
      # p attach.methods
      # p attach.filename
      imagefilename = '/tmp/adanhp_for_mutter_image.jpg'
      File.open(imagefilename, "w+b", 0644) {|f| f.write attach.body.decoded}
      image = File.new(imagefilename)
      if attach.content_type.start_with?('image/')
        mutter = self.new(:user_id => user_id, :content => content)
        mutter.image = image #paperclip 関連が生成される(画像、ディレクトリ)
        mutter.save
        p "### save one image"
      end
    end
  end

   def self.get_content(email)
     body = email.text_part.decoded
     delim = $&
     parts = body.split(delim)
     p parts
     # bodyに「Attachment:」文字列が存在したら削除する（念のため2回）
     idx = parts.index("Attachment:")
     if idx.present?
       parts.delete_at(idx)
       parts.delete_at(idx)
     end
     content = parts.join(" ")
     content.blank? ? "(本文なし)" : content
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
       # [memo] ここではunscopedをしないと、for_sorted_atでソートされてしまうし、unscopedをした場合はid_descまでつけてやらないと再読み込みしてくれない
       last_id = self.unscoped.id_desc.first.id
     }

     if cookies[:update_disp_id].blank?
       cookies[:update_disp_id] = last_id
       return false
     end

     prev_id = cookies[:update_disp_id].to_i
     if last_id > prev_id
       cookies[:update_disp_id] = last_id
       return self.includes_all.parents_mod
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

   def self.create_with_invisible(current_user_id)
      self.create(user_id: current_user_id, invisible_in_timeline: true)
   end

   def self.extra_params(current_user, request = nil, celebration_id = nil)
     params = {}
     params[:user_id] = current_user.id
     params[:ua] = request.env["HTTP_USER_AGENT"] if request.present?
     params[:celebration_id] = celebration_id if celebration_id.present?
     params[:for_sort_at] = Time.now
     return params
   end

end
