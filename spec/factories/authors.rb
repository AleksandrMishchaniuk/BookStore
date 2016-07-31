require 'ffaker'

FactoryGirl.define do
  factory :author do
    first_name    FFaker::Name.first_name
    last_name     FFaker::Name.last_name
    description   FFaker::Lorem.paragraph
  end
end
