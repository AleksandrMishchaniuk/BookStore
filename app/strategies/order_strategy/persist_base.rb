class OrderStrategy::PersistBase

  def save(order)
    raise 'You should inplement method #save'
  end

  def destroy(order)
    raise 'You should inplement method #destroy'
  end

  def prepare(order)
    unless order.kind_of? Order
      raise 'argument sould be instance of Order'
    end
  end

  def prepare_destroy(order)
    prepare(order)
    order.detach_coupon
  end

end
