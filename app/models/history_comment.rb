# == Schema Information
#
# Table name: history_comments
#
#  id         :integer          not null, primary key
#  content    :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  history_id :integer
#  user_id    :integer
#

class HistoryComment < ApplicationRecord
  belongs_to :user
  belongs_to :history

  validates :content, :presence => true
end
