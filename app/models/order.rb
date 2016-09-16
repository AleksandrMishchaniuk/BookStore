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

  after_create :set_coupon_after_save

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
    return 0 unless coupon
    item_total * coupon.discount
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
    cart_items.find { |item| item.book_id == book_id.to_i } ||
    cart_items.new(book_id: book_id, book_count: 0)
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

  def ==(another)
    attributes == another.attributes && cart_items == another.cart_items
  end

  def set_coupon(object)
    if object && !object.used
      self.coupon = object
      self
    elsif object.nil? || object != coupon
      self.coupon = nil
      false
    end
  end

  def coupon
    (persisted?)? super : get_coupon_from_session
  end

  def coupon_id
    coupon.try(:id)
  end

  def coupon=(object)
    return if object == coupon
    raise 'Object shoult be Coupon or NilClass' unless object.kind_of?(Coupon) || object.nil?
    detach_coupon
    object.attach if object
    if persisted?
      super(object)
    else
      save_coupon_to_session(object)
    end
  end

  def detach_coupon
    coupon.detach if coupon
    clear_coupon_in_session
  end

  protected

  def session
    Thread.current[:session]
  end

  def save_coupon_to_session(object)
    session[:coupon_id] = (object)? object.id : nil
  end

  def get_coupon_from_session
    (session[:coupon_id])? Coupon.find(session[:coupon_id]) : nil
  end

  def clear_coupon_in_session
    session[:coupon_id] = nil
  end

  def set_coupon_after_save
    if get_coupon_from_session
      update_attributes(coupon: get_coupon_from_session)
    end
  end

end
