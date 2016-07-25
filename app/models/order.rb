class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :order_state
  belongs_to :shipping_address, class_name: 'Address', foreign_key: :shipping_address
  belongs_to :billing_address, class_name: 'Address', foreign_key: :billing_address
  belongs_to :credit_card
  belongs_to :delivery
  has_many :carts
  has_many :books, through: :carts

  validates :carts, presence: true

  rails_admin do
    edit do
      field :order_state
    end
  end

  alias :cart_items :carts

  def item_total
    cart_items.inject(0) { |sum, item| sum + item.total_price }
  end

  def order_total
    item_total.to_f + ( delivery.try(:price) || 0 )
  end

  def number
    "R#{created_at.strftime("%Y%m%d")}#{id}"
  end

  def save_to_progress
    return false unless save
    unless cart_items.empty?
      cart_items.each { |item| item.save unless item.persisted? }
    end
    true
  end

end
