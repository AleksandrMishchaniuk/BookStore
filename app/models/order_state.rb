class OrderState < ActiveRecord::Base
  has_many :orders

  validates :state, presence: true, length: {maximum: 64}

  rails_admin do
    edit do
      exclude_fields :orders
    end
    object_label_method do
      :state
    end
  end

  class << self
    def in_progress
      find(1)
    end
    def in_queue
      find(2)
    end
    def in_delivery
      find(3)
    end
    def delivered
      find(4)
    end
    def canceled
      find(5)
    end
  end
end
