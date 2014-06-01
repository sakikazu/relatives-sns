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
