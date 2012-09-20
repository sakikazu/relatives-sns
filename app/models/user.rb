# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  acts_as_paranoid

  has_many :mutters
  has_many :celebrations
  has_one :user_ext

  after_save :rel_save

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :encryptable, :encryptor => :authlogic_sha512, :stretches => 20, :pepper => "", # for authlogic algorithm
         :authentication_keys => [:username]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :familyname, :givenname, :root11, :generation, :role, :email, :password, :password_confirmation, :remember_me, :last_request_at

  validates :username, presence: true, uniqueness: true


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
      name = "#{self.user_ext.familyname}#{self.user_ext.givenname}"
    when FULLNICK
      name = "#{self.user_ext.nickname}(#{self.user_ext.familyname}#{self.user_ext.givenname})" if self.user_ext && !self.user_ext.nickname.blank? && !self.user_ext.familyname.blank? && !self.user_ext.givenname.blank?
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

end
