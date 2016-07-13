class Cart < ActiveRecord::Base
  belongs_to :book
  belongs_to :order

  validates :order,       presence: true
  validates :book,        presence: true
  validates :book_count,  presence: true, numericality: {only_integer: true, greater_than: 0}
end
