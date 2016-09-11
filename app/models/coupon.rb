class Coupon < ActiveRecord::Base
  belongs_to :order

  validates :code,       presence: true, length: { is: 4 }, uniqueness: true
  validates :discount,   presence: true, numericality: { less_than: 1, greater_than: 0 }

  scope :used, -> { where(used: true) }
  scope :unused, -> { where(used: false) }

  rails_admin do
    edit do
      exclude_fields :used, :order
    end
  end

  def attach
    update_attributes(used: true) unless used
  end

  def detach
    update_attributes(used: false, order_id: nil)
  end

end
