FactoryGirl.define do
  factory :review do
    sequence(:title)    { FFaker::Lorem.phrase }
    sequence(:text)     { FFaker::Lorem.paragraph }
    sequence(:vote)     { rand(1..5) }
    approved            false
  end
end
