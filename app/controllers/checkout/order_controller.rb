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
          return
        end
      end
      redirect_to edit_checkout_addresses_path
    end

    def confirm
      @step = 4
      check_step! @step
    end

    def to_queue
      @step = 4
      check_step! @step
      @order.order_state = OrderState.in_queue
      @order.save!
      session[:order_in_progress_id] = nil
      @curent_order = @order
      @order = Order.new
      render 'show'
    end

  end
end
