# -*- coding: utf-8 -*-
class BlogImage < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog

  attr_accessible :image

  content_name = "blog"
  has_attached_file :image,
    :styles => {
      :thumb => "150x150>",
      :large => "800x800>"
    },
    :convert_options => { :thumb => ['-quality 70', '-strip']}, #50じゃノイズきつい
    :url => "/upload/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:id/:style/:basename.:extension"
end
