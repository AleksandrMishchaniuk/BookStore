class CreditCard < ActiveRecord::Base
  has_many :orders
end
