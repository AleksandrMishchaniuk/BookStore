FactoryGirl.define do
  factory :category do
    sequence(:name)    {FFaker::Lorem.word}

    factory :category_with_books do
      transient do
        items_count 5
      end
      after :create do |category, evaluator|
        evaluator.items_count.times do
          category.books << create(:book)
        end
      end
    end

  end
end
