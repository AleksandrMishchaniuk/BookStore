class OrderState < ActiveRecord::Base
  has_many :orders

  validates :state, presence: true, length: {maximum: 64}

  rails_admin do
    edit do
      exclude_fields :orders
    end
  end

  class << self
    def in_progress
      find(1)
    end
    def in_queue
      find(2)
    end
  end
end
