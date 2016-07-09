class Address < ActiveRecord::Base
  has_many :billed_orders, class_name: 'Order', foreign_key: :billing_address
  has_many :shiped_orders, class_name: 'Order', foreign_key: :shiping_address
end
