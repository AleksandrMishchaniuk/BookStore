class OrderStrategy::PersistBase

  def initialize(coupon_storage, coupon_key)
    raise 'argument #1 sould be instance of Storage' unless coupon_storage.kind_of? Storage
    raise 'argument #2 sould be instance of Symbol' unless coupon_key.kind_of? Symbol
    @coupon_storage = coupon_storage
    @coupon_key = coupon_key
  end

  def save(order)
    raise 'You should inplement method #save'
  end

  def destroy(order)
    raise 'You should inplement method #destroy'
  end

  def set_coupon(order)
    raise 'You should inplement method #set_coupon'
  end

  def get_coupon(order)
    raise 'You should inplement method #get_coupon'
  end

  protected

  def prepare(order)
    raise 'argument sould be instance of Order' unless order.kind_of? Order
  end

  def prepare_destroy(order)
    prepare(order)
    detach_coupon(order)
  end

  def prepare_set_coupon(order, object)
    raise 'argument #2 shoult be Coupon or NilClass' unless object.kind_of?(Coupon) || object.nil?
    detach_coupon(order)
    object.attach if object
  end

  def detach_coupon(order)
    raise 'argument shoult be instance Order' unless order.kind_of?(Order)
    order.coupon_by_strategy.detach if order.coupon_by_strategy
    @coupon_storage[@coupon_key] = nil
  end

end
