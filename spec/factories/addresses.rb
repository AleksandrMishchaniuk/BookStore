FactoryGirl.define do
  factory :address do
    first_name      FFaker::Name.first_name
    last_name       FFaker::Name.last_name
    address_line    FFaker::Address.street_address
    city            FFaker::Address.city
    country         FFaker::Address.country
    zip             FFaker::AddressUA.zip_code
    phone           FFaker::PhoneNumberMX.international_mobile_phone_number
  end
end
