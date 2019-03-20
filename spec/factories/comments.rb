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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    mutter_id 1
    photo_id 1
    parent_id 1
    parent_type "MyString"
    content "MyText"
  end
end
