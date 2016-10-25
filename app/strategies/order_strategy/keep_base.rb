module OrderStrategy
  # :nodoc:
  class KeepBase
    def initialize(storage)
      raise 'argument #1 sould be instance of Storage' unless storage.is_a? Storage
      @storage = storage
    end

    def keep(_order)
      raise 'You should inplement method #keep'
    end

    def prepare_keep(order)
      raise 'argument sould be instance of Order' unless order.is_a? Order
      @storage.clear
    end
  end
end
