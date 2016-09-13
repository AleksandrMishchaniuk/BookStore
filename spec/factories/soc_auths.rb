FactoryGirl.define do
  factory :soc_auth do
    user
    sequence(:uid)         { FFaker::Lorem.word }
    sequence(:provider)    { FFaker::Lorem.word }
    sequence(:data)        {{
                              first_name: FFaker::Name.first_name,
                              last_name: FFaker::Name.last_name
                            }}
  end
end
