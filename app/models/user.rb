# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  authentication_token   :string(255)
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  deleted_at             :datetime
#  email                  :string(255)      default("")
#  encrypted_password     :string(255)      default(""), not null
#  familyname             :string(255)
#  generation             :integer
#  givenname              :string(255)
#  last_request_at        :datetime
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  password_salt          :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  role                   :integer          default(2), not null
#  root11                 :integer
#  sign_in_count          :integer          default(0)
#  username               :string(255)      default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  parent_id              :integer
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#

class User < ApplicationRecord
  acts_as_paranoid

  has_many :mutters
  has_many :celebrations
  has_one :user_ext
  has_many :user_extensions
  has_one :my_album, class_name: "Album", foreign_key: "owner_id"
  belongs_to :parent, class_name: "User", foreign_key: "parent_id", optional: true
  has_many :children, class_name: "User", foreign_key: "parent_id"

  accepts_nested_attributes_for :user_ext

  attr_writer :login

  before_validation :fill_root11
  after_save :rel_save

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :registerable,
  # :lockable, :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :timeoutable,
         :encryptable, :encryptor => :authlogic_sha512, :stretches => 20, :pepper => "", # for authlogic algorithm
         :authentication_keys => [:login]


  # NOTE: deviseの:validatableを使用しないため手動で定義。理由は、User登録時はログインに必要な情報は必須入力にしたくないため
  validates :email, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }, allow_blank: true
  validates :password, length: { minimum: 4 }, confirmation: { case_sensitive: true }, allow_blank: true

  validates :root11, presence: true
  validates :username, presence: true, uniqueness: true, format: { with: /\A[\w]+\z/i, message: '英数字のみで入力してください.' }
  validates :familyname, presence: true
  validates :givenname, presence: true


  default_scope { where("role != ?", User::TEST_USER) }
  scope :includes_ext, -> { includes("user_ext") }
  scope :myfamily, -> (user) { where(root11: user.root11) }
  scope :notfamily, -> (user) { where.not(root11: user.root11).or(self.where(root11: nil)) }


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


  def login
    @login || self.username || self.email
  end

  def root11_name
    Hash[*ROOT_LIST.flatten.reverse][self.root11]
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

  def fill_root11
    return if self.root11.present? || self.parent_id.blank?
    self.root11 = self.parent&.root11
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

  # NOTE: メールアドレスとユーザー名のどちらでもログイン可能にしたいため、Deviseメソッドをオーバーライド
  # cf. https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  def self.requested_users(limit = nil)
    self.includes_ext.order("last_request_at DESC").limit(limit)
  end

  def editable(user)
    self.admin? || self.myfamily?(user)
  end

  def myfamily?(user)
    user_root11 = if user.is_a?(Hash)
                    user[:root11]
                  else
                    user.fill_root11
                    user.root11
                  end
    self.root11 == user_root11
  end

  # 家系図用のデータ作成
  def self.build_relationed_users
    all_users = self.includes_ext.order("user_exts.birth_day ASC")
    root11_users = all_users.select{ |u| u.parent_id.nil? }
    users = root11_users.map do |user|
      recursive_relation(user, all_users)
    end
    users
  end

  # 家系図用のデータを世代ごとにカウント（A団専用）
  #
  # NOTE: この家系図では、そうへい夫妻と11兄弟を並列にしてしまっているため、人数集計ではその部分は決め打ちするしかない
  # [0] => 合計
  # [1] => 1世代（そうへい、ふさこ）
  # [2] => 2世代（11兄弟）
  # [3] => 3世代（11兄弟の配偶者、子供）
  # [n] => 続いていく
  def self.count_by_generation(relationed_users)
    users_count = [0, 2, 11]
    relationed_users.each do |user|
      gen = 2
      recursive_count_by_generation(users_count, gen, user)
    end
    users_count[0] = users_count.inject(0) { |sum, n| sum + n }
    users_count
  end


  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless self.class.unscoped.where(authentication_token: token).first
    end
  end

  def self.recursive_relation(user, users)
    user_h = {id: user.id,
              root11: user.root11,
              name: user.dispname(User::FULLNICK),
              age_h: user.user_ext.age_h,
              sex_h: user.user_ext.sex_name,
              blood_h: user.user_ext.blood_name,
              address: user.user_ext.address,
              birth_dead_h: user.user_ext.birth_dead_h,
              is_dead: user.user_ext.dead_day.present?,
              image_path: user.user_ext.image? ? user.user_ext.image(:thumb) : "/assets/missing.gif"
    }

    children = users.select{|u| u.parent_id == user.id}
    if children.blank?
      return user_h.merge({has_members_num: 0, family: []})
    else
      has_members_num = 0
      family = []

      children.each do |child|
        has_members_num += 1

        child_h = recursive_relation(child, users)
        family << child_h
        has_members_num += child_h[:has_members_num]
      end
      return user_h.merge({has_members_num: has_members_num, family: family})
    end
  end

  def self.recursive_count_by_generation(users_count, gen, user)
    return if user[:family].blank?
    gen += 1
    users_count[gen] ||= 0
    users_count[gen] += user[:family].size
    user[:family].each do |u|
      recursive_count_by_generation(users_count, gen, u)
    end
  end
end
