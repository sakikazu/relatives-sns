class Board < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  has_many :board_comments
  has_many :update_histories, :as => :content, :dependent => :destroy

  default_scope {order("created_at DESC")}

  validates :title, presence: true

  attr_accessor :sort_at

  content_name = "board"
  has_attached_file :attach,
    :styles => {
      :thumb => "150x150>",
      :large => "800x800>"
    },
    :convert_options => { :thumb => ['-quality 70', '-strip']}, #50じゃノイズきつい
    :url => "/upload/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:id/:style/:basename.:extension"

  validates_attachment_content_type :attach, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", "application/octet-stream"]
end
