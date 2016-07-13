class Delivery < ActiveRecord::Base
  has_many :orders

  validates :type,    presence: true, length: {maximum: 64}
  validates :price,   presence: true, numericality: true

  rails_admin do
    edit do
      exclude_fields :orders
    end
  end
end
