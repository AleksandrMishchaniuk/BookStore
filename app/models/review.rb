class Review < ActiveRecord::Base
  belongs_to :book
  belongs_to :user

  validates :user, presence: true
  validates :book, presence: true
  validates :title, presence: true, length: {maximum: 256}
  validates :text, presence: true, length: {maximum: 1028}
  validates :vote, numericality: {only_integer: true, greater_than: 0, less_than: 6}

  scope :approved, -> { where(approved: true) }

  rails_admin do
    edit do
      field :approved
    end
  end
end
