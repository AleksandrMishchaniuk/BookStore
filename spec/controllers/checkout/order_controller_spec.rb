require 'rails_helper'

RSpec.describe Checkout::OrderController, type: :controller do
  include BeforeAfterActionsSharedExamples

  describe 'GET #start' do
    let(:query) { get :start }

    shared_examples 'order is not valid' do
      context 'order is not valid' do
        before do
          controller.request.env["HTTP_REFERER"] = cart_path
          order.carts = []
        end
        it 'redirects to :back' do
          query
          expect(response).to redirect_to controller.request.env["HTTP_REFERER"]
        end
      end
    end

    context 'when order is persisted' do
      let(:order){ create(:order) }
      before { controller.instance_variable_set(:@order, order) }
      it 'redirects to checkout addresses page' do
        query
        expect(response).to redirect_to edit_checkout_addresses_path
      end
      include_examples 'does not call :check_order method'
      include_examples 'calls :save_order_in_progress method'
    end
    context 'when order is not persisted' do
      let(:order){ build(:order) }
      let(:state){ create(:state_in_progress) }
      before do
        controller.instance_variable_set(:@order, order)
        state
      end
      it 'redirects to checkout addresses page' do
        query
        expect(response).to redirect_to edit_checkout_addresses_path
      end
      it 'saves order' do
        query
        expect(order).to be_persisted
      end
      it 'changes order state' do
        expect{ query }.to change{ order.order_state }.from(nil).to(state)
      end
      include_examples 'does not call :check_order method'
      include_examples 'order is not valid'
      include_examples 'calls :save_order_in_progress method'
    end #'when order is not persisted
  end # 'GET #start'

  shared_context 'order on confirm step' do
    let(:order){ create(:order) }
    before do
      controller.instance_variable_set(:@order, order)
      order.billing_address = create(:address)
      order.shipping_address = create(:address)
      order.delivery = create(:delivery)
      order.credit_card = create(:credit_card)
    end
  end

  describe 'GET #confirm' do
    let(:query) { get :confirm }
    include_context 'order on confirm step'
    include_examples 'calls :check_order method'
    include_examples 'calls :save_order_in_progress method'
    include_examples 'calls :check_step! method'
    it 'renders tamplate :confirm' do
      query
      expect(response).to render_template 'confirm'
    end
  end # 'GET #confirm'

  describe 'GET #to_queue' do
    let(:query) { get :to_queue }
    let(:old_state) { create(:state_in_progress) }
    let(:new_state) { create(:state_in_queue) }
    include_context 'order on confirm step'
    before do
      order.order_state = old_state
      new_state
    end
    include_examples 'calls :check_order method'
    include_examples 'calls :save_order_in_progress method'
    include_examples 'calls :check_step! method'
    it 'renders tamplate :show' do
      query
      expect(response).to render_template 'show'
    end
    it 'changes order state' do
      expect{ query }.to change{ order.order_state }.from(old_state).to(new_state)
    end
    it 'set @order as new order' do
      query
      expect(assigns(:order)).to be_new_record
    end
    it 'set @curent_order as confirmed order' do
      query
      expect(assigns(:curent_order)).to eq(order)
    end
  end # 'GET #to_queue'

end
