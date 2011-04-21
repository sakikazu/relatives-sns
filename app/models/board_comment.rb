class BoardComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :board

  content_name = "board"
  has_attached_file :attach,
    :styles => {
      :thumb => "150x150>",
      :large => "800x800>"
    },
    :url => "/uploads/#{content_name}/:board/_res/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploads/#{content_name}/:board/_res/:id/:style/:basename.:extension"

end
