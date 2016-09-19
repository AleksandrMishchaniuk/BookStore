FactoryGirl.define do
  factory :coupon do
    sequence(:code)     { rand(1000..9999) }
    sequence(:discount) { rand(0.01..0.99) }
    used                false
  end
end
