class User::OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders_in_queue = current_user.orders.in_queue
    @orders_in_delivery = current_user.orders.in_delivery
    @orders_delivered = current_user.orders.delivered
  end

  def show
    @viewing_order = current_user.orders.find(params[:id].to_i)
  rescue
    redirect_to user_orders_path
  end

end
