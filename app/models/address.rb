# :nodoc:
class Address < ActiveRecord::Base
  has_many :billing_for_orders,  class_name: 'Order',
                                 foreign_key: :billing_address
  has_many :shipping_for_orders, class_name: 'Order',
                                 foreign_key: :shipping_address
  belongs_to :shipping_for_user, class_name: 'User',
                                 foreign_key: :shipping_for_user
  belongs_to :billing_for_user,  class_name: 'User',
                                 foreign_key: :billing_for_user

  validates :first_name,      presence: true, length: { maximum: 64 }
  validates :last_name,       presence: true, length: { maximum: 64 }
  validates :address_line,    presence: true, length: { maximum: 512 }
  validates :city,            presence: true, length: { maximum: 255 }
  validates :country,         presence: true, length: { maximum: 255 }
  validates :zip,             presence: true, length: { maximum: 15 },
                              numericality: { only_integer: true }
  validates :phone,           presence: true,
                              phone: { possible: true, types: [:voip, :mobile] }

  rails_admin do
    include_all_fields
    field :shipping_for_user
    field :billing_for_user
    list do
      exclude_fields :created_at, :updated_at
    end
  end
end
