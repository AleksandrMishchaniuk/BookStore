class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :order_state
  belongs_to :shipping_address, class_name: 'Address', foreign_key: :shipping_address
  belongs_to :billing_address, class_name: 'Address', foreign_key: :billing_address
  belongs_to :credit_card
  belongs_to :delivery
  has_many :carts
  has_many :books, through: :carts

  validates :book, presence: true

  rails_admin do
    edit do
      field :order_state
    end
  end

  alias :cart_items :carts

  def item_total
    0
  end

  def order_total
    0
  end
end
