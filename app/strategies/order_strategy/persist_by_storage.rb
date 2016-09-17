class OrderStrategy::PersistByStorage < OrderStrategy::PersistBase

  def initialize(coupon_storage, coupon_key, order_storage, order_key)
    super(coupon_storage, coupon_key)
    raise 'argument #3 sould be instance of Storage' unless coupon_storage.kind_of? Storage
    raise 'argument #4 sould be instance of Symbol' unless order_key.kind_of? Symbol
    @order_storage = order_storage
    @order_key = order_key
  end

  def save(order)
    prepare(order)
    @order_storage[@order_key] = order.cart_items_to_array
  end

  def destroy(order)
    prepare_destroy(order)
    order.cart_items.delete_all
  end

  def get_coupon(order)
    prepare(order)
    ( @coupon_storage[@coupon_key] ) ? Coupon.find( @coupon_storage[@coupon_key] ) : nil
  end

  def set_coupon(order, coupon)
    prepare(order)
    return coupon if coupon == order.coupon_by_strategy
    prepare_set_coupon(order, coupon)
    @coupon_storage[@coupon_key] = coupon.try(:id)
  end

end
