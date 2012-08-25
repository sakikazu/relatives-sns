# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  # acts_as_paranoid

  has_many :mutters
  has_many :celebrations
  has_one :user_ext

  after_save :rel_save

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :fullname, :role, :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body


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


  def self.find_or_create(username, password)
    user = find_by_username(username)
    if user.blank?
      user = create!(:username => username, :password => password, :password_confirmation => password)
    end
    return user
  end

  def self.find_or_create2(username, password, fullname, email, role)
    user = find_by_username(username)
    if user.blank?
      user = create!(username: username, password: password, password_confirmation: password, fullname: fullname, email: email, role: role)
    end
    return user
  end

  def admin?
    self.role == ADMIN
  end

  def role_name
    Hash[*ROLE.flatten.reverse][self.role]
  end

  def dispname(type = NICKNAME, user_set_only = false)
    name = ""
    case type
    when NICKNAME
      name = self.user_ext.nickname if self.user_ext
    when FULLNAME
      name = "#{self.user_ext.firstname}#{self.user_ext.lastname}" if self.user_ext 
    when FULLNICK
      name = "#{self.user_ext.nickname}(#{self.user_ext.firstname}#{self.user_ext.lastname})" if self.user_ext && !self.user_ext.nickname.blank? && !self.user_ext.firstname.blank? && !self.user_ext.lastname.blank?
    end

    if name.blank? and not user_set_only
      name = self.username
    end
    return Sanitize.clean(name, Sanitize::Config::BASIC)
  end

  def rel_save
    self.user_ext ||= UserExt.create
  end

end
