FactoryGirl.define do
  factory :credit_card do
    number                       '4024007190664085'
    sequence(:code)              { rand(100..999) }
    sequence(:expiration_date)   { FFaker::Time.date }
  end
end
