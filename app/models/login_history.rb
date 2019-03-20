# == Schema Information
#
# Table name: login_histories
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class LoginHistory < ApplicationRecord
  belongs_to :user
end
