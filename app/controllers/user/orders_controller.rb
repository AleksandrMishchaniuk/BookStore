class User::OrdersController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @orders_in_queue = current_user.orders.where(order_state: OrderState.in_queue)
    @orders_in_delivery = current_user.orders.where(order_state: OrderState.in_delivery)
    @orders_delivered = current_user.orders.where(order_state: OrderState.delivered)
  end

  def show
    @viewing_order = current_user.orders.find(params[:id])
  end

end
