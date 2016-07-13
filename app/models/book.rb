class Book < ActiveRecord::Base
  has_and_belongs_to_many :authors
  has_and_belongs_to_many :categories
  has_many :carts
  has_many :orders, through: :carts
  has_many :reviews

  validates :title,               presence: true, length: {maximum: 64}
  validates :short_description,   presence: true, length: {maximum: 128}
  validates :full_description,    presence: true, length: {maximum: 1024}
  validates :price,               presence: true, numericality: true
  validates :authors,             presence: true

  mount_uploader :image, ImageUploader

  rails_admin do
    configure :image, :carrierwave
    exclude_fields :carts, :orders, :reviews
    list do
      exclude_fields :image, :short_description, :full_description
    end
    show do
      include_fields :reviews, :orders
    end
  end
end
