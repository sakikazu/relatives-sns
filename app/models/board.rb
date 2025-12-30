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
  belongs_to :mutter, optional: true
  # todo BoardCommentは画像持ちなので、汎用化はちょっと置いとこう
  # has_many :comments, as: :parent
  has_many :board_comments
  has_many :update_histories, :as => :content, :dependent => :destroy

  scope :recent, lambda { order('created_at DESC') }

  validates :title, presence: true

  attr_accessor :sort_at

  has_one_attached :image

  IMAGE_VARIANTS = {
    thumb: { resize_to_limit: [150, 150] },
    large: { resize_to_limit: [800, 800] }
  }.freeze

  IMAGE_CONTENT_TYPES = ["image/jpg", "image/jpeg", "image/png", "image/gif", "application/octet-stream"].freeze

  validate :image_content_type

  def image_variant(name)
    return nil unless image.attached?
    option = IMAGE_VARIANTS[name]
    return nil if option.blank?
    image.variant(**option)
  end

  def image_content_type
    return unless image.attached?
    return if IMAGE_CONTENT_TYPES.include?(image.content_type)

    errors.add(:image, "の形式が不正です")
  end
end
