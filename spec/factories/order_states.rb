FactoryGirl.define do
  factory :order_state do
    state FFaker::Lorem.word

    factory :state_in_progress do
      id_of_state 1
    end
    factory :state_in_queue do
      id_of_state 2
    end
  end
end
