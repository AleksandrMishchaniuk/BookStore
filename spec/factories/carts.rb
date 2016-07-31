FactoryGirl.define do
  factory :cart do
    book
    book_count { rand(1..10) }
  end
end
