class Mutter < ActiveRecord::Base
  belongs_to :user
  belongs_to :celebration

  before_save :trans_space
  validates_presence_of :content

  MUTTER_DATA_VISIBLE = 12

  content_name = "mutter"
  has_attached_file :image,
    :styles => {
      :thumb => "150x150>",
      :large => "800x800>"
    },
    :convert_options => { :thumb => ['-quality 70', '-strip']}, #50じゃノイズきつい
    :url => "/uploads/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploads/#{content_name}/:id/:style/:basename.:extension"

  def trans_space
    #auto_linkでURLの後に全角スペースが入るとリンクが延長されてしまうため、半角スペースに変換
    self.content.gsub!("　", " ")
  end

  def view_content
    if self.celebration.present?
      "【祝】[#{self.celebration.user.dispname}さんへ] #{self.content}"
    else
      self.content
    end
  end

  # -------------------------------------
  # メールからつぶやき、画像を取得する
  # -------------------------------------
  require 'net/imap'
  def self.create_from_mail
    imap, mail_uids = self.get_gmail_inbox_uids
    mail_uids.each do |uid|
      email = TMail::Mail.parse(imap.uid_fetch(uid,'RFC822').first.attr['RFC822'])
      self.create_from_mail2(email)
#sakikazu これなくても閲覧済みになった
      imap.store(uid,"+FLAGS",[:Seen])    #mail readed
      #imap.store(uid,'+FLAGS',[:Deleted]) #delete mail
      imap.expunge
    end

    # 切断する
    imap.logout
    p "IMAP LOGOUT"
  end

  def self.get_gmail_inbox_uids
    config = YAML.load(File.read(File.join(Rails.root, 'config', 'gmail.yml')))

    # GmailにIMAPで接続、ログインする
    imap = Net::IMAP.new(config['host'],config['port'],true)
    imap.login(config['username'],config['password']) # ID、パスワード
    p "IMAP LOGIN --------------------"

    # 受信箱を開く
    imap.select('INBOX')
    p 'IMAP SELECT INBOX --------------------'
    mail_uids = imap.uid_search(["UNSEEN"])

    [imap, mail_uids]
  end

  # ファイルが添付されてないとMutterを作成しない
  def self.create_from_mail2(email)
    # check -- タイトルは正しいか、user_idは取得できたか、ファイルが添付されているか
    sub = email.subject
    title_check = [sub.index("[a-dan-hp]").present?, sub.index("[user_id]").present?].all?
    u = email.subject.split("[user_id]")[1]
    u_check = u.present? && u =~ /\d/
    return if [title_check, u_check, email.has_attachments?].any?{|x| x.blank?}

    user_id = u.to_i

    content = self.get_content(email)
p content

    #メールの判定などのコード(省略)  ←って何をすべきなんだろう？
    img = email.attachments.first
    # temp = Tempfile::new("a-dan_mutter", "#{Rails.root}/tmp")
    # temp.write(img.read)
    mutter = self.new(:user_id => user_id, :content => content)
    mutter.image = img #paperclip 関連が生成される(画像、ディレクトリ)
    mutter.save
    # mutter.update_attributes(:image_file_name => img.original_filename, :image_content_type => img.content_type)
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
end
