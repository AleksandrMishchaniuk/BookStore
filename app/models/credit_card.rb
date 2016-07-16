class CreditCard < ActiveRecord::Base
  has_many :orders

  validates :number,            presence: true, credit_card_number: true
  validates :expiration_month,  presence: true,
                                numericality: {
                                  only_integer: true,
                                  greater_than: 0,
                                  less_than: 13
                                }
  validates :expiration_year,   presence: true,
                                numericality: {
                                  only_integer: true,
                                  greater_than: Time.new.year.to_i,
                                  less_than: Time.new.year.to_i + 15
                                }
  validates :code,              presence: true,
                                numericality: {only_integer: true},
                                length: {is: 3}
end
