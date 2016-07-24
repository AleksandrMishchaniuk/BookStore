module Checkout
  class AddressesController < BaseController
    def edit
      @step = 1
      @order.billing_address  ||= current_user.try(:billing_address)  || Address.new
      @order.shipping_address ||= current_user.try(:shipping_address) || Address.new
    end

    def update
      @step = 1
      if @order.billing_address
        @order.billing_address.update(address_params :billing)
      else
        @order.billing_address = Address.create(address_params :billing)
      end
      if params[:once_address]
        @order.shipping_address = @order.billing_address
      else
        if @order.shipping_address && @order.shipping_address != @order.billing_address
          @order.shipping_address.update(address_params :shipping)
        else
          @order.shipping_address = Address.create(address_params :shipping)
        end
      end
      if @order.billing_address.errors.any? || @order.shipping_address.errors.any?
        render :edit
      else
        @order.save!
        redirect_to edit_checkout_delivery_path
      end
    end

    protected

    def address_params(type)
      params.require(:order).require(type).require(:address).permit(:first_name, :last_name,
            :address_line, :city, :country, :zip, :phone)
    end
  end
end
