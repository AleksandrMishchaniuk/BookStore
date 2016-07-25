module Checkout
  class PaymentController < BaseController

    def edit
      @step = 3
      check_step! @step
      @order.credit_card ||= CreditCard.new
    end

    def update
      @step = 3
      if @order.credit_card
        @order.credit_card.update(credit_card_params)
      else
        @order.credit_card = CreditCard.create(credit_card_params)
      end
      if @order.credit_card.errors.any?
        render :edit
      else
        @order.save!
        redirect_to checkout_confirm_path
      end
    end

    protected

    def credit_card_params
      params.require(:credit_card).permit(:number, :code, :expiration_date)
    end

  end
end
