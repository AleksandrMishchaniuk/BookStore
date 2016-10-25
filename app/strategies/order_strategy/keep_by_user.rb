module OrderStrategy
  # :nodoc:
  class KeepByUser < KeepBase
    def initialize(storage, user)
      super(storage)
      raise 'argument #2 sould be instance of User' unless user.is_a? User
      @user = user
    end

    def keep(order)
      prepare_keep(order)
      @user.orders << order unless @user.orders.include? order
    end
  end
end
