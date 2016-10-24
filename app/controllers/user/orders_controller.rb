# :nodoc:
class User::OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders_in_queue = Order.accessible_by(current_ability).in_queue
    @orders_in_delivery = Order.accessible_by(current_ability).in_delivery
    @orders_delivered = Order.accessible_by(current_ability).delivered
  end

  def show
    @viewing_order = Order.find(params[:id].to_i)
    authorize! :show, @viewing_order
  rescue
    redirect_to user_orders_path
  end
end
