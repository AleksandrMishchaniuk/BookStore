FactoryGirl.define do
  factory :address do
    sequence(:first_name)     { FFaker::Name.first_name }
    sequence(:last_name)      { FFaker::Name.last_name }
    sequence(:address_line)   { FFaker::Address.street_address }
    sequence(:city)           { FFaker::Address.city }
    sequence(:country)        { FFaker::Address.country }
    sequence(:zip)            { FFaker::AddressUA.zip_code }
    sequence(:phone) { FFaker::PhoneNumberMX.international_mobile_phone_number }
  end
end
