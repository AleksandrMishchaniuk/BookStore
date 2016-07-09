class Delivery < ActiveRecord::Base
  has_many :orders

  rails_admin do
    edit do
      exclude_fields :orders
    end
  end
end
