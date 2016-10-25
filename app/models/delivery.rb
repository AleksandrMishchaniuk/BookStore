# :nodoc:
class Delivery < ActiveRecord::Base
  has_many :orders

  validates :delivery_type,     presence: true, length: { maximum: 64 }
  validates :price,             presence: true, numericality: true

  rails_admin do
    list do
      exclude_fields :created_at, :updated_at
    end
    edit do
      exclude_fields :orders
    end
    object_label_method do
      :delivery_type
    end
  end
end
