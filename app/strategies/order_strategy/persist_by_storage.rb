class OrderStrategy::PersistByStorage < OrderStrategy::PersistBase

  def initialize(storage, key)
    if storage.kind_of? Storage
      @storage = storage
    else
      raise 'argument #1 sould be instance of Storage'
    end
    if key.kind_of? Symbol
      @key = key
    else
      raise 'argument #2 sould be instance of Symbol'
    end
  end

  def save(order)
    prepare(order)
    @storage[@key] = order.cart_items_to_array
  end

  def destroy(order)
    prepare_destroy(order)
    order.cart_items.delete_all
  end

end
