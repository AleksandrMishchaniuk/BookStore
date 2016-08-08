require 'rails_helper'

RSpec.describe Checkout::PaymentController, type: :controller do
  include BeforeAfterActionsSharedExamples

  shared_context 'order on checkout payment step' do
    let(:order){ create(:order) }
    before do
      controller.instance_variable_set(:@order, order)
      order.billing_address = create(:address)
      order.shipping_address = create(:address)
      order.delivery = create(:delivery)
    end
  end

  describe 'GET #edit' do
    include_context 'order on checkout payment step'
    let(:query) { get :edit }
    include_examples 'calls :check_order method'
    include_examples 'calls :save_order_in_progress method'
    include_examples 'calls :check_step! method'
    it 'renders tamplate :edit' do
      query
      expect(response).to render_template :edit
    end
    it 'sets variable @order.credit_card' do
      query
      expect(assigns(:order).credit_card).to be_kind_of(CreditCard)
    end
  end # 'GET #edit'

  describe 'PUT #update' do
    include_context 'order on checkout payment step'
    let(:resource_params) { attributes_for(:credit_card) }
    let(:query) { put :update, credit_card: resource_params }
    include_examples 'calls :check_order method'
    include_examples 'calls :save_order_in_progress method'
    context 'when credit card params are valid' do
      context 'when order does not have credit card yet' do
        before(:each) { order.credit_card = nil }
        it 'redirects to confirm page' do
          query
          expect(response).to redirect_to checkout_confirm_path
        end
        it 'creates credit card' do
          expect(CreditCard).to receive(:create).and_return(CreditCard.create(resource_params))
          query
          expect(order.credit_card).to be_kind_of(CreditCard)
        end
      end
      context 'when order already has credit card' do
        before(:each) { order.credit_card = create(:credit_card) }
        it 'redirects to confirm page' do
          query
          expect(response).to redirect_to checkout_confirm_path
        end
        it 'creates credit card' do
          expect(order.credit_card).to receive(:update)
          query
        end
      end
    end # 'when credit card params are valid'
    context 'when credit card params are not valid' do
      before { resource_params.each_key{ |k| resource_params[k] = '' } }
      it 'renders edit page' do
        query
        expect(response).to render_template :edit
      end
      it 'sets errors' do
        query
        expect(order.credit_card.errors).to_not be_empty
      end
    end # 'when credit card params are not valid'
  end # 'PUT #update'

end
