class Celebration < ActiveRecord::Base
  belongs_to :user
  has_many :mutters
end
