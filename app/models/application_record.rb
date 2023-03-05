class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  NO_IMAGE_PATH = '/images/noimage.gif'

  # 個数がCOLUMNSの倍数になるように、nilで埋める
  def self.fill_up_blank(records, column)
    surplus  = records.size % column
    return records if surplus.zero?
    fill_up_size = column - surplus
    return records + Array.new(fill_up_size, nil)
  end
end
