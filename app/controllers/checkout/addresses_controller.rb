module Checkout
  # :nodoc:
  class AddressesController < BaseController
    def edit
      @step = 1
      order.billing_address  ||= current_user.try(:billing_address)  ||
                                 Address.new(current_user.try(:data))
      order.shipping_address ||= current_user.try(:shipping_address) ||
                                 Address.new(current_user.try(:data))
    end

    def update
      @step = 1
      order.create_or_update_billing_address(address_params(:billing))
      if params[:once_address]
        order.shipping_address = order.billing_address
      else
        order.create_or_update_shipping_address(address_params(:shipping))
      end
      order.save!
      if order.billing_address.errors.any? || order.shipping_address.errors.any?
        render :edit
      else
        redirect_to edit_checkout_delivery_path
      end
    end

    protected

    def address_params(type)
      params.require(:order).require(type).require(:address)
            .permit(:first_name, :last_name, :address_line, :city,
                    :country, :zip, :phone)
    end
  end
end
