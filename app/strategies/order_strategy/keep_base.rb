class OrderStrategy::KeepBase

  def initialize(storage)
    if storage.kind_of? Storage
      @storage = storage
    else
      raise 'argument #1 sould be instance of Storage'
    end
  end

  def keep(order)
    raise 'You should inplement method #keep'
  end

  def prepare_keep(order)
    unless order.kind_of? Order
      raise 'argument sould be instance of Order'
    end
    @storage.clear
  end

end
