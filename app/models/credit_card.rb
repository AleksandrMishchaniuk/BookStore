class CreditCard < ActiveRecord::Base
  has_many :orders

  validates :number,            presence: true, credit_card_number: true
  validates :expiration_date,   presence: true, date: true
  validates :code,              presence: true,
                                numericality: {only_integer: true},
                                length: {is: 3}
end
