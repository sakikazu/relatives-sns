# == Schema Information
#
# Table name: celebrations
#
#  id             :integer          not null, primary key
#  anniversary_at :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :integer
#

class Celebration < ApplicationRecord
  belongs_to :user
  has_many :mutters
end
