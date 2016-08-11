FactoryGirl.define do
  factory :book do
    sequence(:title)               {FFaker::Movie.title}
    sequence(:short_description)   {FFaker::Lorem.paragraph}
    sequence(:full_description)    {FFaker::Lorem.paragraphs}
    sequence(:image)               {FFaker::Avatar.image}
    sequence(:price)               { rand(0.01..50.00) }

    transient do
      authors_count 2
    end

    before :create do |book, evaluator|
      evaluator.authors_count.times do
        book.authors << create(:author)
      end
    end

  end
end
