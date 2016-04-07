class User < ActiveRecord::Base
  acts_as_paranoid

  has_many :mutters
  has_many :celebrations
  has_one :user_ext
  has_many :user_extensions
  has_one :my_album, class_name: "Album", foreign_key: "owner_id"
  belongs_to :parent, class_name: "User", foreign_key: "parent_id"
  has_many :children, class_name: "User", foreign_key: "parent_id"

  accepts_nested_attributes_for :user_ext

  after_save :rel_save

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :encryptable, :encryptor => :authlogic_sha512, :stretches => 20, :pepper => "", # for authlogic algorithm
         :authentication_keys => [:username]

  validates :username, presence: true, uniqueness: true

  default_scope { where("role != ?", User::TEST_USER) }
  scope :includes_ext, -> { includes("user_ext") }


  #role
  ADMIN = 0
  SUB_ADMIN = 1
  MEMBER = 2
  TEST_USER = 3
  ROLE = [["管理者", ADMIN], ["sub管理者", SUB_ADMIN], ["メンバー", MEMBER], ["テストユーザー", TEST_USER]]

  #dispname type
  FULLNAME = 1
  NICKNAME = 2
  FULLNICK = 3

  #root11
  R1 = 0
  R2 = 1
  R3 = 2
  R4 = 3
  R5 = 4
  R6 = 5
  R7 = 6
  R8 = 7
  R9 = 8
  R10 = 9
  R11 = 10
  ROOT_LIST = [["輝美", R1], ["由美子", R2], ["順子", R3], ["真澄", R4], ["泰弘", R5], ["睦子", R6], ["満喜子", R7], ["浩敏", R8], ["徹", R9], ["ゆかり", R10], ["英樹" ,R11]]

  def root11_name
    Hash[*ROOT_LIST.flatten.reverse][self.root11]
  end


  def self.find_or_create(username, password)
    user = find_by_username(username)
    if user.blank?
      user = create!(:username => username, :password => password, :password_confirmation => password)
    end
    return user
  end

  def self.find_or_create2(username, password, familyname, givenname, email, role, root11, generation)
    user = self.find_by_username(username)
    if user.blank?
      user = self.create!(username: username, password: password, password_confirmation: password, familyname: familyname, givenname: givenname, email: email, role: role, root11: root11, generation: generation)
    end
    return user
  end

  def admin?
    self.role == ADMIN
  end

  def role_name
    Hash[*ROLE.flatten.reverse][self.role]
  end


  # 表示名
  # ※familynameとgivennameは、UserとUserExtともに存在するが、Userは基本管理者が設定するものなので、表示上はUserExtが優先される
  #
  # @param type
  # @param trueにするとユーザーが設定していない設定値（管理者が登録するフルネームとか）は表示されない
  #
  def dispname(type = NICKNAME, user_set_only = false)
    name = ""
    case type
    when NICKNAME
      name = self.user_ext.nickname if self.user_ext
    when FULLNAME
      name = "#{self.familyname}#{self.givenname}"
    when FULLNICK
      name = "#{self.familyname}#{self.givenname}"
      name += "(#{self.user_ext.nickname})" if self.user_ext && !self.user_ext.nickname.blank?
    end

    # 名前が設定されていなかったら、管理者設定の名前を使う
    if name.blank? and not user_set_only
      name = "#{self.familyname}#{self.givenname}"
    end

    return Sanitize.clean(name, Sanitize::Config::BASIC)
  end

  def rel_save
    self.user_ext ||= UserExt.create
  end

  # 指定時間（分指定）内にリクエストしたユーザー数
  def self.recent_request_count(minute = 5)
    where("last_request_at > ?", Time.now() - minute * 60).size
  end


  def save_extension(key, value)
    ext = UserExtension.where(user_id: self.id, key: key).first
    if ext.present?
      ext.update_attributes(value: value)
    else
      UserExtension.create(user_id: self.id, key: key, value: value)
    end
  end
  def find_extension(key)
    self.user_extensions.where(key: key).first
  end

  # 2014-01-25、deviseから、token_authenticationが削除されたので、それを復活。推奨はされてないのかな？ほんとは下記にならって、models/concernsで定義したい
  # http://stackoverflow.com/questions/18931952/devise-token-authenticatable-deprecated-what-is-the-alternative
  def self.find_by_authentication_token(authentication_token = nil)
    if authentication_token
      where(authentication_token: authentication_token).first
    end
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def reset_authentication_token!
    self.authentication_token = generate_authentication_token
    save
  end

  def profile_path
    user_ext.image? ? user_ext.image(:small) : "/assets/noimage.gif"
  end

  def self.requested_users(limit = nil)
    self.includes_ext.order("last_request_at DESC").limit(limit)
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless self.class.unscoped.where(authentication_token: token).first
    end
  end
end
