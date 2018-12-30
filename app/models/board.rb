# == Schema Information
#
# Table name: boards
#
#  id                  :integer          not null, primary key
#  attach_content_type :string(255)
#  attach_file_name    :string(255)
#  attach_file_size    :integer
#  attach_updated_at   :datetime
#  deleted_at          :datetime
#  description         :text(65535)
#  title               :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  mutter_id           :integer
#  user_id             :integer
#

class Board < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  belongs_to :mutter
  # todo BoardCommentは画像持ちなので、汎用化はちょっと置いとこう
  # has_many :comments, as: :parent
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
