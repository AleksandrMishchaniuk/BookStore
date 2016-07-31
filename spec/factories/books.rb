FactoryGirl.define do
  factory :book do
    title               FFaker::Movie.title
    short_description   FFaker::Lorem.paragraph
    full_description    FFaker::Lorem.paragraphs
    image               FFaker::Avatar.image
    price               { rand(0.01..50.00) }

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
