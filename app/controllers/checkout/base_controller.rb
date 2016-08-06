module Checkout
  class BaseController < ::ApplicationController
    before_filter :check_order, except: :start

    def check_step!(step)
      return if step == 1
      unless @order.billing_address
        redirect_to edit_checkout_addresses_path
        return
      end
      return if step == 2
      unless @order.delivery
        redirect_to edit_checkout_delivery_path
        return
      end
      return if step == 3
      unless @order.credit_card
        redirect_to edit_checkout_payment_path
        return
      end
      return if step == 4
      unless @order.order_state == OrderState.in_queue
        redirect_to checkout_confirm_path
        return
      end
    end

    protected

    def check_order
      redirect_to cart_path unless @order.persisted?
    end
  end
end
