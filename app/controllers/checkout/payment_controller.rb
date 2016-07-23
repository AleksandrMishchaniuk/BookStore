module Checkout
  class PaymentController < BaseController

    def edit
      @step = 3
      # check_step! @step
      @order.credit_card ||= CreditCard.new
    end

  end
end
