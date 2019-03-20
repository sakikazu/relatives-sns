# == Schema Information
#
# Table name: rankings
#
#  id             :integer          not null, primary key
#  classification :integer
#  content_type   :string(255)
#  nice_count     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  content_id     :integer
#

require 'spec_helper'

describe Ranking do
  pending "add some examples to (or delete) #{__FILE__}"
end
