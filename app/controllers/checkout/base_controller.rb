module Checkout
  class BaseController < ::ApplicationController
    before_action :define_order_in_progress

    def define_order_in_progress
      @order = Order.in_progress || Order.new
    end

    def check_step!(step)
      return if step == 1
      redirect_to edit_checkout_addresses_path unless @order.billing_address
      return if step == 2
      redirect_to edit_checkout_delivery_path unless @order.delivery
      return if step == 3
      redirect_to edit_checkout_payment_path unless @order.credit_card
      return if step == 4
      redirect_to checkout_confirm_path unless @order.order_state == OrderState.in_queue
    end
  end
end
