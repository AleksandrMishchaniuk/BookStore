class Ability
  include CanCan::Ability

  def store_data
    [Author, Book, Category, Delivery, OrderState]
  end
  def order_data
    [Order, Address, Cart, CreditCard]
  end

  def initialize(user)
    can :read, :all
    can :create, User
    can :manage, order_data
    can :read, Review
    if user
      can :create, Review
      cannot :create, User
      if user.admin?
        can :access, :rails_admin
        can :dashboard
        if /\/admin\/?/.match(request.original_fullpath)
          can :manage, store_data
          cannot :manage, order_data
          cannot :manage, Review
          can :read, Coupon
          can [:update, :destroy], Coupon, order: nil
          can [:read, :update], [Order, Review]
        end
      end
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end

  def request
    Thread.current[:request]
  end
end
