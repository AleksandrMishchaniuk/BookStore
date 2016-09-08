FactoryGirl.define do
  factory :order do

    transient do
      items_count 3
    end

    after :build do |order, evaluator|
      evaluator.items_count.times do
        order.carts << build(:cart)
      end
    end

    factory :order_in_progress do
      association :order_state, factory: :state_in_progress
    end

    factory :order_in_queue do
      association :order_state, factory: :state_in_queue
    end

  end
end
