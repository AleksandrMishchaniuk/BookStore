# :nodoc:
class Book < ActiveRecord::Base
  has_and_belongs_to_many :authors
  has_and_belongs_to_many :categories
  has_many :carts
  has_many :orders, through: :carts
  has_many :reviews

  validates :title,               presence: true, length: { maximum: 128 }
  validates :short_description,   presence: true, length: { maximum: 512 }
  validates :full_description,    presence: true, length: { maximum: 2048 }
  validates :price,               presence: true, numericality: true

  mount_uploader :image, ImageUploader

  rails_admin do
    configure :image, :carrierwave
    exclude_fields :carts, :orders, :reviews
    list do
      exclude_fields :image, :short_description, :full_description,
                     :created_at, :updated_at
    end
    show do
      include_fields :reviews, :orders
    end
  end

  class << self
    def bestsellers(limit = 5)
      ids = joins('LEFT OUTER JOIN carts ON carts.book_id = books.id')
            .select('books.id, COALESCE(sum(book_count),0) AS selles')
            .group('books.id').order('selles DESC').limit(limit)
      books = includes(:authors).find(*ids)
      books_hash = books.each_with_object({}) do |book, hash|
        hash[book.id] = book
      end
      ids.map { |i| books_hash[i.id] }
    end
  end

  def approved_reviews
    reviews.approved
  end
end
