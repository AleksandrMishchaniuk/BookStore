class OrderStrategy::SaveBase

  def save(order)
    raise 'You should inplement method #save'
  end

  def prepare_save(order)
    unless order.kind_of? Order
      raise 'argument sould be instance of Order'
    end
  end

end
