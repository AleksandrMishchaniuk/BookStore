module Checkout
  class DeliveryController < BaseController

    def edit
      @step = 2
      check_step! @step
      @deliveries = Delivery.all
    end

    def update
      @step = 2
      @order.delivery = Delivery.find(delivery_params[:delivery])
      @order.save!
      redirect_to edit_checkout_payment_path
    end

    protected

    def delivery_params
      params.require(:order).permit(:delivery)
    end

  end
end
