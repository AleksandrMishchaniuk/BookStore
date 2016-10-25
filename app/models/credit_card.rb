# :nodoc:
class CreditCard < ActiveRecord::Base
  has_many :orders

  validates :number,            presence: true, credit_card_number: true
  validates :expiration_date,   presence: true, date: true
  validates :code,              presence: true,
                                numericality: { only_integer: true },
                                length: { is: 3 }

  rails_admin do
    exclude_fields :code
    list do
      exclude_fields :created_at, :updated_at
    end
  end
end
