class OrderStrategy::KeepByStorageNotPersist < OrderStrategy::KeepBase

  def initialize(storage, key)
    super(storage)
    if key.kind_of? Symbol
      @key = key
    else
      raise 'argument #2 sould be instance of Symbol'
    end
  end

  def keep(order)
    prepare_keep(order)
    @storage[@key] = order.cart_items_to_array
  end

end
