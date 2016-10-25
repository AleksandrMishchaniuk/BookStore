module OrderStrategy
  # :nodoc:
  class KeepByStorageNotPersist < KeepBase
    def initialize(storage, key)
      super(storage)
      raise 'argument #2 sould be instance of Symbol' unless key.is_a? Symbol
      @key = key
    end

    def keep(order)
      prepare_keep(order)
      @storage[@key] = order.cart_items_to_array
    end
  end
end
