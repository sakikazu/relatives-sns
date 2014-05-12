class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable

  # 管理者はフォームからは登録不可にする [except] registerable, recoverable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable,
         :authentication_keys => [:email]

end
