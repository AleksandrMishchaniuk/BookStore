require 'rails_helper'

RSpec.describe Checkout::DeliveryController, type: :controller do
  include BeforeAfterActionsSharedExamples

  shared_context 'order on checkout delivery step' do
    let(:order){ create(:order) }
    let(:deliveries){ (1..3).map { create(:delivery) } }
    before do
      controller.instance_variable_set(:@order, order)
      order.billing_address = create(:address)
      order.shipping_address = create(:address)
      deliveries
    end
  end

  describe 'GET #edit' do
    include_context 'order on checkout delivery step'
    let(:query) { get :edit }
    include_examples 'calls :check_order method'
    include_examples 'calls :save_order_in_progress method'
    include_examples 'calls :check_step! method'
    it 'renders tamplate :edit' do
      query
      expect(response).to render_template :edit
    end
    it 'sets variable @deliveries' do
      query
      expect(assigns(:deliveries)).to_not be_empty
      assigns(:deliveries).each do |item|
        expect(item).to be_kind_of(Delivery)
      end
    end
  end # 'GET #edit'

  describe 'PUT #update' do
    include_context 'order on checkout delivery step'
    let(:delivery) { deliveries[rand(0...deliveries.size)] }
    let(:query) { put :update, order:{ delivery: delivery.id } }
    include_examples 'calls :check_order method'
    include_examples 'calls :save_order_in_progress method'
    include_examples 'calls :check_step! method'
    context 'when delivery id is valid' do
      it 'redirect to checkout payment page' do
        query
        expect(response).to redirect_to edit_checkout_payment_path
      end
      it 'sets order.delivery' do
        query
        expect(order.delivery).to eq(delivery)
      end
    end
    context 'when delivery id is not valid' do
      let(:query) { put :update, order:{ delivery: 0 } }
      let(:referer) { edit_checkout_delivery_path }
      before { controller.request.env['HTTP_REFERER'] = referer }
      it 'redirects to back' do
        query
        expect(response).to redirect_to referer
      end
    end
  end # 'PUT #update'

end
