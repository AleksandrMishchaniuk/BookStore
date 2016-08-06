require 'rails_helper'

RSpec.describe Checkout::BaseController, type: :controller do
  include OdrderInProgressHelpers
  before { allow(controller).to receive(:redirect_to) }

  describe '#check_step!' do
    before(:each) do
      order_by_id_from_session
      controller.send(:define_order_in_progress)
      assigns(:order).billing_address = create(:address)
      assigns(:order).delivery = create(:delivery)
      assigns(:order).credit_card = create(:credit_card)
      assigns(:order).order_state = create(:state_in_queue)
    end

    context 'when "step" more than 4 and ' do
      context 'when order does not have only billing address' do
        before do
          assigns(:order).billing_address = nil
        end
        it 'redirects to checkout addresses page' do
          expect(controller).to receive(:redirect_to).with(edit_checkout_addresses_path)
          controller.check_step!(5)
        end
      end

      context 'when order does not have only delivery method' do
        before do
          assigns(:order).delivery = nil
        end
        it 'redirects to checkout addresses page' do
          expect(controller).to receive(:redirect_to).with(edit_checkout_delivery_path)
          controller.check_step!(5)
        end
      end

      context 'when order does not have only payment data' do
        before do
          assigns(:order).credit_card = nil
        end
        it 'redirects to checkout addresses page' do
          expect(controller).to receive(:redirect_to).with(edit_checkout_payment_path)
          controller.check_step!(5)
        end
      end

      context 'when order only does not state "in queue"' do
        before do
          assigns(:order).order_state = create(:state_in_progress)
        end
        it 'redirects to checkout addresses page' do
          expect(controller).to receive(:redirect_to).with(checkout_confirm_path)
          controller.check_step!(5)
        end
      end
    end

    context 'when order has all properties and' do
      (1..5).each do |step|
        context "when step is #{step}" do
          it 'does not redirect' do
            expect(controller).to_not receive(:redirect_to)
            controller.check_step!(step)
          end
        end
      end
    end

  end

  describe '#check_order' do
    context 'whem order is not persisted' do
      before do
        order_from_session_by_cart_items
        controller.send(:define_order_in_progress)
      end
      it 'redirects to cart page' do
        expect(controller).to receive(:redirect_to).with(cart_path)
        controller.send(:check_order)
      end
    end
    context 'whem order is persisted' do
      before do
        order_by_id_from_session
        controller.send(:define_order_in_progress)
      end
      it 'redirects to cart page' do
        expect(controller).to_not receive(:redirect_to)
        controller.send(:check_order)
      end
    end
  end

end
