class Book < ActiveRecord::Base
  has_and_belongs_to_many :authors
  has_and_belongs_to_many :categories
  has_many :carts
  has_many :orders, through: :carts
  has_many :reviews

  mount_uploader :image, ImageUploader

  rails_admin do
    configure :image, :carrierwave
    exclude_fields :carts, :orders, :reviews
    list do
      exclude_fields :image, :short_description, :full_description
    end
  end
end
