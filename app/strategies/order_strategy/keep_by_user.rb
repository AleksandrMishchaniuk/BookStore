class OrderStrategy::KeepByUser < OrderStrategy::KeepBase

  def initialize(storage, user)
    super(storage)
    if user.kind_of? User
      @user = user
    else
      raise 'argument #2 sould be instance of User'
    end
  end

  def keep(order)
    prepare_keep(order)
    @user.orders << order unless @user.orders.include? order
  end

end
