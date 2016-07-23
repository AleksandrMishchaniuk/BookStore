module Checkout
  class DeliveryController < BaseController

    def edit
      @step = 2
      # check_step! @step
      @deliveries = Delivery.all
    end
  end
end
