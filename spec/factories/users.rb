FactoryGirl.define do
  factory :user do
    sequence(:email)     { FFaker::Internet.email }
    sequence(:password)  { FFaker::Internet.password }
  end
end
