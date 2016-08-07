module Checkout
  class BaseController < ::ApplicationController
    before_filter :check_order, except: :start

    def check_step!(step)
      return if step == 1
      return redirect_to edit_checkout_addresses_path unless @order.billing_address
      return if step == 2
      return redirect_to edit_checkout_delivery_path unless @order.delivery
      return if step == 3
      return redirect_to edit_checkout_payment_path unless @order.credit_card
      return if step == 4
      return redirect_to checkout_confirm_path unless @order.order_state == OrderState.in_queue
    end

    protected

    def check_order
      redirect_to cart_path unless @order.persisted?
    end
  end
end
