# :nodoc:
class OrderFactory
  STORAGE_KEY = :current_order
  COUPON_STORAGE_KEY = :current_coupon
  PERSISTED_KEY = :order_in_progress_id
  NOT_PERSISTED_KEY = :cart_items
  COUPON_KEY = :coupon_id

  def initialize(context)
    unless context.is_a? ApplicationController
      raise 'argument sould be instance of ApplicationController'
    end
    @context = context
  end

  def order
    order_of_user = current_user.order_in_progress if user_signed_in?
    if order_storage[PERSISTED_KEY]
      Order.find(order_storage[PERSISTED_KEY])
    elsif order_of_user
      order_of_user
    elsif order_storage[NOT_PERSISTED_KEY]
      order_from_order_storage(NOT_PERSISTED_KEY)
    else
      Order.new
    end
  end

  def persist_strategy(order)
    raise 'argument sould be instance of Order' unless order.is_a? Order
    if order.persisted?
      OrderStrategy::PersistByDb.new(coupon_storage, COUPON_KEY)
    else
      OrderStrategy::PersistByStorage.new(coupon_storage, COUPON_KEY,
                                          order_storage, NOT_PERSISTED_KEY)
    end
  end

  def keep_strategy(order)
    raise 'argument sould be instance of Order' unless order.is_a? Order
    if order.persisted?
      if user_signed_in?
        OrderStrategy::KeepByUser.new(order_storage, current_user)
      else
        OrderStrategy::KeepByStoragePersist.new(order_storage, PERSISTED_KEY)
      end
    else
      OrderStrategy::KeepByStorageNotPersist.new(order_storage, NOT_PERSISTED_KEY)
    end
  end

  protected

  def order_storage
    @order_storage ||= Storage.new(@context, STORAGE_KEY)
  end

  def coupon_storage
    @coupon_storage ||= Storage.new(@context, COUPON_STORAGE_KEY)
  end

  def current_user
    @context.current_user
  end

  def user_signed_in?
    @context.user_signed_in?
  end

  def order_from_order_storage(key)
    return false unless order_storage[key]
    order = Order.new
    order.carts = order_storage[key].map { |item| Cart.new(item) }
    order
  end
end
