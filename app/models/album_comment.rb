# == Schema Information
#
# Table name: album_comments
#
#  id         :integer          not null, primary key
#  content    :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  album_id   :integer
#  user_id    :integer
#

class AlbumComment < ApplicationRecord
  belongs_to :user
  belongs_to :album

  validates_presence_of :content
end
