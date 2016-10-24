class Ability
  include CanCan::Ability

  def store_data
    [Author, Book, Category, Delivery]
  end

  def initialize(user)
    if user
      can :create, Review
      can :read, Order, user_id: user.id
      if user.admin?
        can :access, :rails_admin
        can :dashboard
        if self.class.request.original_fullpath =~ %r{\/admin\/?}
          can :manage, store_data
          cannot :create, Review
          can :read, [Coupon, OrderState]
          can [:update, :destroy], Coupon, order: nil
          can [:read, :update], [Order, Review]
          cannot :update, Order, order_state: OrderState.in_progress
        end
      end
    end
  end

  class << self
    def request
      Thread.current[:request]
    end
  end
end
