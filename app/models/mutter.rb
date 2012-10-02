# -*- coding: utf-8 -*-
class Mutter < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  belongs_to :celebration
  belongs_to :parent, class_name: "Mutter", foreign_key: "reply_id"
  has_many :children, class_name: "Mutter", foreign_key: "reply_id"
  has_many :nices, :as => :asset

  before_save :trans_space
  after_create :update_sort_at
  validates_presence_of :content
  attr_accessor :search_word, :action_flg, :year, :month

  attr_accessible :user_id, :content, :reply_id, :image_file_name, :image_content_type, :image_file_size, :image_updated_at, :created_at, :updated_at, :celebration_id, :image, :for_sort_at, :year, :month, :search_word, :action_flg, :ua

  MUTTER_DATA_VISIBLE = 12

  @@imap = nil

  content_name = "mutter"
  has_attached_file :image,
    :styles => {
      :thumb => "150x150>",
      :large => "800x800>"
    },
    :convert_options => { :thumb => ['-quality 70', '-strip']}, #50じゃノイズきつい
    :url => "/upload/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:id/:style/:basename.:extension"

  scope :user_is, lambda {|n| n.present? ? where(:user_id => n).id_desc : id_desc}

  # [memo]こうやってそれぞれにuser、user_extを指定するようにすると、最初のリクエスト時にはやっぱ時間短縮されてる。
  # 二度目のリクエストではキャッシュされるらしく、それぞれに指定しなかった時と同じ速度になる。
  scope :includes_all, includes([{:user => :user_ext}, {:children => {:nices => {:user => :user_ext}}}, {:nices => {:user => :user_ext}}])
  scope :parents_mod, where("mutters.reply_id IS NULL") #「parents」が自動で定義されていたので。返り値がArrayだったので使えなかった
  scope :id_desc, order("mutters.id DESC")
  scope :id_asc, order("mutters.id ASC")

  default_scope order("for_sort_at DESC")


  def trans_space
    #auto_linkでURLの後に全角スペースが入るとリンクが延長されてしまうため、半角スペースに変換
    self.content.gsub!("　", " ")
  end

  # ソート用の日時カラムを更新。レスされた親のも更新する。
  def update_sort_at
    # self.for_sort_at = Time.now
    self.update_attributes(for_sort_at: Time.now)
    if self.parent.present?
      self.parent.update_attributes(for_sort_at: Time.now)
    end
  end

  def view_content
    if self.celebration.present?
      "<span class='badge badge-warning'>【祝】 #{self.celebration.user.try(:dispname)}さんへ</span> #{self.content}"
    else
      self.content
    end
  end

  # -------------------------------------
  # メールからつぶやき、画像を取得する
  # -------------------------------------
  require 'net/imap'
  def self.create_from_mail
    mail_uids = self.get_gmail_inbox_uids
    mail_uids.each do |uid|
      email = TMail::Mail.parse(@@imap.uid_fetch(uid,'RFC822').first.attr['RFC822'])
      self.create_from_mail2(email)
      # 一応明示的に既読にする(なくてもparseの時点で既読になる)
      @@imap.store(uid,"+FLAGS",[:Seen])    #mail readed
      # @@imap.store(uid,'+FLAGS',[:Deleted]) #delete mail
      @@imap.expunge
    end

    # 切断する
    @@imap.logout
    p "IMAP LOGOUT"
  end

  # GmailにIMAPで接続し、未読メールを取得
  def self.get_gmail_inbox_uids
    config = YAML.load(File.read(File.join(Rails.root, 'config', 'gmail.yml')))
    @@imap = Net::IMAP.new(config['host'],config['port'],true)
    @@imap.login(config['username'],config['password']) # ID、パスワード
    p "IMAP LOGIN --------------------"

    # 受信箱を開く
    @@imap.select(config['gmail_label'])
    p "IMAP SELECT #{config['gmail_label']} --------------------"
    mail_uids = @@imap.uid_search(["UNSEEN"])
    mail_uids
  end

  # ファイルが添付されてないとMutterを作成しない
  def self.create_from_mail2(email)
    # check -- タイトルは正しいか、user_idは取得できたか、ファイルが添付されているか
    sub = email.subject
    title_check = [sub.index("[a-dan-hp]").present?, sub.index("[user_id]").present?].all?
    u = email.subject.split("[user_id]")[1]
    u_check = u.present? && u =~ /\d/
    return if [title_check, u_check, email.has_attachments?].any?{|x| x.blank?}
    p 'mail check ok -------------'

    user_id = u.to_i
    content = self.get_content(email)
    p content

    #メールの判定などのコード(省略)  ←って何をすべきなんだろう？
    img = email.attachments.first
    mutter = self.new(:user_id => user_id, :content => content)
    mutter.image = img #paperclip 関連が生成される(画像、ディレクトリ)
    mutter.save
    p "save one image"
  end

   def self.get_content(email)
     body = email.body.toutf8
     delim = $&
     parts = body.split(delim)
     # bodyに「Attachment:」文字列が存在したら、
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
       return self.includes_all.parents_mod.limit(20)
     else
       return false
     end
   end

end
