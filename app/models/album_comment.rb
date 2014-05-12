class AlbumComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :album

  validates_presence_of :content
end
