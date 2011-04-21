class Board < ActiveRecord::Base
  belongs_to :user
  has_many :board_comments
  has_many :update_histories, :as => :assetable, :dependent => :destroy

  attr_accessor :sort_at

  acts_as_paranoid

  content_name = "board"
  has_attached_file :attach,
    :styles => {
      :thumb => "150x150>",
      :large => "800x800>"
    },
    :url => "/uploads/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploads/#{content_name}/:id/:style/:basename.:extension"

end
