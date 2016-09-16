class OrderStrategy::SaveByStorage < OrderStrategy::SaveBase

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
    raise 'You should inplement method #save'
  end

end
