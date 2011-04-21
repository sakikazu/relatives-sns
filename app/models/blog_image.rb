class BlogImage < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog

  content_name = "blog"
  has_attached_file :image,
    :styles => {
      :thumb => "150x150>",
      :large => "800x800>"
    },
    :url => "/uploads/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploads/#{content_name}/:id/:style/:basename.:extension"

end
