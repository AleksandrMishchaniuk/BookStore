module Checkout
  class OrderController < BaseController

    def start
      unless @order.persisted?
        @order.order_state = OrderState.in_progress
        if @order.save_to_progress
          session[:cart_items] = nil
          (current_user)? current_user.orders << @order: session[:order_in_progress_id] = @order.id
        else
          redirect_to :back
        end
      end
      redirect_to edit_checkout_addresses_path
    end

  end
end
