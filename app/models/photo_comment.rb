# == Schema Information
#
# Table name: photo_comments
#
#  id         :integer          not null, primary key
#  content    :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  photo_id   :integer
#  user_id    :integer
#

class PhotoComment < ApplicationRecord
  belongs_to :photo
  belongs_to :user
end
