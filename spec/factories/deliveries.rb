FactoryGirl.define do
  factory :delivery do
    delivery_type   FFaker::Lorem.word
    price           { rand(1.0..20.0) }
  end
end
