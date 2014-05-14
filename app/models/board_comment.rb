class BoardComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :board

  content_name = "board"
  has_attached_file :attach,
    :styles => {
      :thumb => "150x150>",
      :large => "800x800>"
    },
    :convert_options => { :thumb => ['-quality 70', '-strip']}, #50じゃノイズきつい
    :url => "/upload/#{content_name}/:board/_res/:id/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:board/_res/:id/:style/:basename.:extension"

  validates_attachment_content_type :attach, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", "application/octet-stream"]
end
