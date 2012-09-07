# -*- coding: utf-8 -*-
class Board < ActiveRecord::Base
  belongs_to :user
  has_many :board_comments
  has_many :update_histories, :as => :content, :dependent => :destroy

  attr_accessor :sort_at

  acts_as_paranoid

  content_name = "board"
  has_attached_file :attach,
    :styles => {
      :thumb => "150x150>",
      :large => "800x800>"
    },
    :convert_options => { :thumb => ['-quality 70', '-strip']}, #50じゃノイズきつい
    :url => "/upload/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:id/:style/:basename.:extension"

end
