# :nodoc:
class OrderState < ActiveRecord::Base
  has_many :orders

  validates :state,       presence: true, length: { maximum: 64 }
  validates :id_of_state, numericality: { only_integer: true, greater_than: 0 }

  rails_admin do
    list do
      exclude_fields :created_at, :updated_at
    end
    edit do
      exclude_fields :orders
    end
    object_label_method do
      :state
    end
  end

  class << self
    def in_progress
      find_by id_of_state: 1
    end

    def in_queue
      find_by id_of_state: 2
    end

    def in_delivery
      find_by id_of_state: 3
    end

    def delivered
      find_by id_of_state: 4
    end

    def canceled
      find_by id_of_state: 5
    end
  end
end
