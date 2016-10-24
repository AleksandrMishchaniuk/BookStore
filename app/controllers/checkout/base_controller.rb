module Checkout
  # :nodoc:
  class BaseController < ::ApplicationController
    before_filter :check_order, except: :start

    def check_step!(step)
      check_configs.each do |conf|
        return if step == conf[:step]
        return redirect_to conf[:path] unless conf[:condition]
      end
    end

    protected

    def check_order
      redirect_to cart_path unless @order.persisted?
    end

    def check_configs
      [
        {
          step: 1,
          path: edit_checkout_addresses_path,
          condition: @order.billing_address
        },
        {
          step: 2,
          path: edit_checkout_delivery_path,
          condition: @order.delivery
        },
        {
          step: 3,
          path: edit_checkout_payment_path,
          condition: @order.credit_card
        },
        {
          step: 4,
          path: checkout_confirm_path,
          condition: @order.order_state == OrderState.in_queue
        }
      ]
    end
  end
end
