module Checkout
  class OrderController < BaseController

    def start
      unless @order.persisted?
        @order.order_state = OrderState.in_progress
        return redirect_to :back unless @order.save_to_progress
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
      @curent_order = @order
      @order = Order.new
      render 'show'
    end

  end
end
