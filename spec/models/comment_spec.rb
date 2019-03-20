# == Schema Information
#
# Table name: comments
#
#  id          :integer          not null, primary key
#  content     :text(65535)
#  parent_type :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  mutter_id   :integer
#  parent_id   :integer
#  photo_id    :integer
#  user_id     :integer
#

require 'spec_helper'

describe Comment do
  pending "add some examples to (or delete) #{__FILE__}"
end
