class User < ActiveRecord::Base
  acts_as_authentic

  has_many :mutters
  has_one :user_ext

  after_save :rel_save

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


  def admin?
    self.role == ADMIN
  end

  def role_name
    Hash[*ROLE.flatten.reverse][self.role]
  end

  def dispname(type = NICKNAME, only_user_set = false)
    name = ""
    case type
    when NICKNAME
      name = self.user_ext.nickname if self.user_ext
    when FULLNAME
      name = "#{self.user_ext.firstname}#{self.user_ext.lastname}" if self.user_ext 
    when FULLNICK
      name = "#{self.user_ext.nickname}(#{self.user_ext.firstname}#{self.user_ext.lastname})" if self.user_ext && !self.user_ext.nickname.blank? && !self.user_ext.firstname.blank? && !self.user_ext.lastname.blank?
    end

    if name.blank? and not only_user_set
      name = self.login
    end
    return name
  end

  def rel_save
    self.user_ext ||= UserExt.create
  end
end
