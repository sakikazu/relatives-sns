# == Schema Information
#
# Table name: blog_images
#
#  id                 :integer          not null, primary key
#  image_content_type :string(255)
#  image_file_name    :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  blog_id            :integer
#

class BlogImage < ApplicationRecord
  belongs_to :blog

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
