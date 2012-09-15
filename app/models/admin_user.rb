class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable

  # 管理者はフォームからは登録不可にする [except] registerable, recoverable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable,
         :authentication_keys => [:email]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

end
