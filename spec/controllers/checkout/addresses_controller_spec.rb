require 'rails_helper'

RSpec.describe Checkout::AddressesController, type: :controller do
  include OdrderInProgressHelpers

  shared_examples 'calls :check_order method' do
    it 'calls :chek_order method' do
      expect(controller).to receive(:check_order)
      query
    end
  end

  shared_examples 'addresses are not persisted' do
    it do
      query
      expect(assigns(:order).billing_address).to be_kind_of(Address)
      expect(assigns(:order).shipping_address).to be_kind_of(Address)
      expect(assigns(:order).billing_address).to_not be_persisted
      expect(assigns(:order).shipping_address).to_not be_persisted
    end
  end

  describe 'GET #edit' do
    let(:query) { get :edit }

    include_examples 'calls :check_order method'
    context 'when user is not loged in' do
      before { order_by_id_from_session }
      include_examples 'addresses are not persisted'
    end

    context 'when user is loged in' do
      before { order_by_current_user }
      let(:user) { controller.current_user }
      context 'when user does not have addresses' do
        include_examples 'addresses are not persisted'
      end
      context 'when user has addresses' do
        before do
          user.billing_address = create(:address)
          user.shipping_address = create(:address)
        end
        it do
          query
          expect(assigns(:order).billing_address).to be_kind_of(Address)
          expect(assigns(:order).shipping_address).to be_kind_of(Address)
          expect(assigns(:order).billing_address).to be_persisted
          expect(assigns(:order).shipping_address).to be_persisted
          expect(assigns(:order).billing_address).to eq(user.billing_address)
          expect(assigns(:order).shipping_address).to eq(user.shipping_address)
        end
      end
    end
  end

  shared_examples 'redirects to checkout delivery page' do
    it 'redirects to checkout delivery page' do
      query
      expect(response).to redirect_to edit_checkout_delivery_path
    end
  end

  describe 'POST #update' do
    let(:order) { order_by_id_from_session }
    let(:billing_address_parameters) { attributes_for(:address) }
    let(:shipping_address_parameters) { attributes_for(:address) }
    before do
      order
      allow(controller).to receive(:order).and_return(order)
    end

    context 'when addresses are valid' do

      context 'when request has both addresses' do
        let(:query) do
          put :update, order: {
                                billing:{address: billing_address_parameters},
                                shipping:{address: shipping_address_parameters}
                              }
        end
        include_examples 'calls :check_order method'
        include_examples 'redirects to checkout delivery page'
        context 'when order does not have addresses yet' do
          before do
            controller.send(:define_order_in_progress)
            order.billing_address = nil
            order.shipping_address = nil
          end
          it 'creates addresses for order' do
            expect(Address).to receive(:create) .with(billing_address_parameters)
                                                .and_return(Address.new)
            expect(Address).to receive(:create) .with(shipping_address_parameters)
                                                .and_return(Address.new)
            query
            expect(order.billing_address).to be_kind_of(Address)
            expect(order.shipping_address).to be_kind_of(Address)
            expect(order.billing_address).to_not eq(order.shipping_address)
          end
        end
        context 'when order already has addresses' do
          before do
            controller.send(:define_order_in_progress)
            order.billing_address = create(:address)
            order.shipping_address = create(:address)
            order.save!
          end
          it 'calles :update method' do
            expect( order.billing_address ).to receive(:update)  .with(billing_address_parameters)
            expect( order.shipping_address ).to receive(:update) .with(shipping_address_parameters)
            query
          end
          it 'creates not equil addresses' do
            query
            expect(order.billing_address).to_not eq(order.shipping_address)
          end
        end
      end

      context 'when request has billig address and parameter :once_address' do
        let(:query) do
          put :update, {order: {
                                billing:{address: billing_address_parameters},
                                shipping:{address: shipping_address_parameters}
                              },
                       once_address: 1}
        end
        include_examples 'calls :check_order method'
        include_examples 'redirects to checkout delivery page'
        it 'creates equil addresses' do
          query
          expect(order.billing_address).to eq(order.shipping_address)
        end
      end

    end # when addresses are valid

    context 'when one of addresses is not valid' do
      before {shipping_address_parameters.each_key { |k| shipping_address_parameters[k] = '' }}
      let(:query) do
        put :update, order: {
                              billing:{address: billing_address_parameters},
                              shipping:{address: shipping_address_parameters}
                            }
      end
      include_examples 'calls :check_order method'
      context 'when order does not have addresses yet' do
        before do
          controller.send(:define_order_in_progress)
          order.billing_address = nil
          order.shipping_address = nil
        end
        it 'renders edit page' do
          query
          expect(response).to render_template :edit
        end
        it 'does not save address with wrong parameters' do
          query
          expect(order.billing_address).to be_persisted
          expect(order.shipping_address).to_not be_persisted
        end
      end
      context 'when order already has addresses' do
        before do
          controller.send(:define_order_in_progress)
          order.billing_address = create(:address)
          order.shipping_address = create(:address)
          order.save!
        end
        it 'renders edit page' do
          query
          expect(response).to render_template :edit
        end
        it 'does not change addresses' do
          query
          expect{query}.to_not change{ order.billing_address }
          expect{query}.to_not change{ order.shipping_address }
        end
      end
    end # 'when one of addresses is not valid'

  end # 'POST #update'

end
