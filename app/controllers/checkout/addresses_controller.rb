module Checkout
  class AddressesController < BaseController
    def edit
      @step = 1
      @order.billing_address  ||= current_user.try(:billing_address)  || Address.new
      @order.shipping_address ||= current_user.try(:shipping_address) || Address.new
    end
  end
end
