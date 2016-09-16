class OrderFactory
  STORAGE_KEY = :current_order
  PERSISTED_KEY = :order_in_progress_id
  NOT_PERSISTED_KEY = :cart_items

  def initialize(context)
    unless context.kind_of? ApplicationController
      raise 'argument sould be instance of ApplicationController'
    end
    @context = context
  end

  def order
    order_of_user = current_user.order_in_progress if user_signed_in?
    if storage[PERSISTED_KEY]
      Order.find(storage[PERSISTED_KEY])
    elsif order_of_user
      order_of_user
    elsif storage[NOT_PERSISTED_KEY]
      order_from_storage(NOT_PERSISTED_KEY)
    else
      Order.new
    end
  end

  def save_strategy(order)
    unless order.kind_of? Order
      raise 'argument sould be instance of Order'
    end
    if order.persisted?
      OrderStrategy::SaveByDb.new
    else
      OrderStrategy::SaveByStorage.new(storage, NOT_PERSISTED_KEY)
    end
  end

  def keep_strategy(order)
    unless order.kind_of? Order
      raise 'argument sould be instance of Order'
    end
    if order.persisted?
      if user_signed_in?
        OrderStrategy::KeepByUser.new(storage, current_user)
      else
        OrderStrategy::KeepByStoragePersist.new(storage, PERSISTED_KEY)
      end
    else
      OrderStrategy::KeepByStorageNotPersist.new(storage, NOT_PERSISTED_KEY)
    end
  end

  protected

  def storage
    @storage ||= Storage.new(@context, STORAGE_KEY)
  end

  def current_user
    @context.current_user
  end

  def user_signed_in?
    @context.user_signed_in?
  end

  def order_from_storage(key)
    return false unless storage[key]
    order = Order.new
    order.carts = storage[key].map { |item| Cart.new(item) }
    order
  end

end
