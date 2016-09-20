class Order < ActiveRecord::Base
  include OrderAdmin

  attr_reader :persist_strategy, :keep_strategy

  belongs_to :user
  belongs_to :order_state
  belongs_to :shipping_address, class_name: 'Address', foreign_key: :shipping_address
  belongs_to :billing_address, class_name: 'Address', foreign_key: :billing_address
  belongs_to :credit_card
  belongs_to :delivery
  has_many :carts
  has_many :books, through: :carts
  has_one  :coupon

  validates :carts, presence: true

  scope :in_progress, -> { find_by(order_state: OrderState.in_progress) }
  scope :in_queue, -> { where(order_state: OrderState.in_queue) }
  scope :in_delivery, -> { where(order_state: OrderState.in_delivery) }
  scope :delivered, -> { where(order_state: OrderState.delivered) }

  after_create :in_progress
  before_destroy :destroy_cart_items
  after_destroy :destroy_binded_objects

  alias :cart_items :carts

  def persist_strategy=(val)
    unless val.kind_of? OrderStrategy::PersistBase
      raise 'argument sould be instance of OrderStrategy::PersistBase'
    end
    @persist_strategy = val
  end

  def keep_strategy=(val)
    unless val.kind_of? OrderStrategy::KeepBase
      raise 'argument sould be instance of OrderStrategy::KeepBase'
    end
    @keep_strategy = val
  end

  def keep_by_strategy
    @keep_strategy.keep(self)
  end

  def save_by_strategy
    @persist_strategy.save(self)
  end

  def destroy_by_strategy
    @persist_strategy.destroy(self)
  end

  def item_total
    cart_items.inject(0) { |sum, item| sum + item.total_price }.to_f
  end

  def item_discount
    return 0 unless coupon_by_strategy
    item_total * coupon_by_strategy.discount
  end

  def item_total_with_discount
    item_total - item_discount
  end

  def order_total
    item_total_with_discount + ( delivery.try(:price) || 0 )
  end

  def number
    "R#{created_at.strftime("%Y%m%d")}#{id}"
  end

  def cart_items_to_array
    cart_items.map { |item| item.attributes }
  end

  def find_or_build_cart_item(book_id)
    cart_item(book_id) || cart_items.new(book_id: book_id, book_count: 0)
  end

  def cart_item(book_id)
    cart_items.find { |item| item.book_id == book_id.to_i }
  end

  def save_with_cart_items
    return false unless save
    unless cart_items.empty?
      cart_items.each { |item| item.save! }
    end
    true
  end

  def destroy_binded_objects
    billing_address.try(:destroy!)
    shipping_address.try(:destroy!)
    credit_card.try(:destroy!)
  end

  def destroy_cart_items
    cart_items.each { |item| item.destroy! } unless cart_items.empty?
  end

  def ==(another)
    attributes == another.try(:attributes) && cart_items == another.try(:cart_items)
  end

  def set_coupon(object)
    if object && !object.used
      self.coupon_by_strategy=(object)
      self
    elsif object.nil? || object != coupon_by_strategy
      self.coupon_by_strategy=(nil)
      false
    else
      self
    end
  end

  def coupon_by_strategy
    @persist_strategy.try(:get_coupon, self) || coupon
  end

  def coupon_id_by_strategy
    coupon.try(:id)
  end

  def coupon_by_strategy=(object)
    @persist_strategy.set_coupon(self, object)
  end

  def in_progress
    update(order_state: OrderState.in_progress)
  end

end
