class Order::AddressesController < ApplicationController
  def edit
    @step = 1
    @order = Order.in_progress || Order.new
    @order.billing_address  ||= current_user.try(:billing_address)   || Address.new
    @order.shipping_address ||= current_user.try(:shipping_address)  || Address.new
  end
end
