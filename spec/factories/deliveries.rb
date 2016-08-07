FactoryGirl.define do
  factory :delivery do
    sequence(:delivery_type)   { FFaker::Lorem.word }
    sequence(:price)           { rand(1.0..20.0) }
  end
end
