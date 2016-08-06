FactoryGirl.define do
  factory :credit_card do
    number            '4024007190664085'
    code              { rand(100..999) }
    expiration_date   FFaker::Time.date
  end
end
