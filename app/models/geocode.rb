# == Schema Information
#
# Table name: geocodes
#
#  id         :integer          not null, primary key
#  address    :string(255)
#  lat        :float(24)
#  lng        :float(24)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Geocode < ApplicationRecord
end
