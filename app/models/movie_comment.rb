# == Schema Information
#
# Table name: movie_comments
#
#  id         :integer          not null, primary key
#  content    :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  movie_id   :integer
#  user_id    :integer
#

class MovieComment < ApplicationRecord
  belongs_to :user
  belongs_to :movie
end
