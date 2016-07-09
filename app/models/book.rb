class Book < ActiveRecord::Base
  has_and_belongs_to_many :authors
  has_and_belongs_to_many :categories
  has_many :carts
  has_many :orders, through: :carts
  has_many :reviews

  rails_admin do
    edit do
      exclude_fields :carts, :orders, :reviews
    end
  end
end
