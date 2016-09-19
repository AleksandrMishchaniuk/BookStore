require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  include OdrderInProgressHelpers

  # describe "#define_order_in_progress" do
  #   it "should set object of Order to @order" do
  #     controller.send(:define_order_in_progress)
  #     expect(assigns(:order)).to be_kind_of(Order)
  #   end
  #
  #   context "when session has saved :cart_items hash" do
  #     it do
  #       order = order_from_session_by_cart_items
  #       controller.send(:define_order_in_progress)
  #       expect(assigns(:order)).to eq(order)
  #     end
  #   end
  #
  #   context "when session has saved :cart_items and :order_in_progress_id hashes" do
  #     it do
  #       order_not_persisted = order_from_session_by_cart_items
  #       order_persisted_with_session = order_by_id_from_session
  #       controller.send(:define_order_in_progress)
  #       expect(assigns(:order)).to eq(order_persisted_with_session)
  #       expect(assigns(:order)).to_not eq(order_not_persisted)
  #     end
  #   end
  #
  #   context "when current user has order in progress and session has saved :cart_items hash" do
  #     it do
  #       order_persisted_with_user = order_by_current_user
  #       order_not_persisted = order_from_session_by_cart_items
  #       controller.send(:define_order_in_progress)
  #       expect(assigns(:order)).to eq(order_persisted_with_user)
  #       expect(assigns(:order)).to_not eq(order_not_persisted)
  #     end
  #   end
  #
  #   context "when current user has order in progress and session has saved :cart_items and :order_in_progress_id hashes" do
  #     it do
  #       order_not_persisted = order_from_session_by_cart_items
  #       order_persisted_with_session = order_by_id_from_session
  #       order_persisted_with_user = order_by_current_user
  #       controller.send(:define_order_in_progress)
  #       expect(assigns(:order)).to eq(order_persisted_with_session)
  #       expect(assigns(:order)).to_not eq(order_not_persisted)
  #       expect(assigns(:order)).to_not eq(order_persisted_with_user)
  #     end
  #   end
  # end # #define_order_in_progress
  #
  # shared_examples 'when order is not persisted' do
  #   it 'changes storage[:cart_items]' do
  #     expect{ controller.send(:save_order_in_progress) }.to change{ storage[:cart_items] }
  #   end
  #   it 'sets storage[:order_in_progress_id] to nil' do
  #     controller.send(:save_order_in_progress)
  #     expect(storage[:order_in_progress_id]).to be_nil
  #   end
  # end
  #
  # describe '#save_order_in_progress' do
  #   let(:storage) { Storage.new(controller, OrderFactory::STORAGE_KEY) }
  #   let(:user) { create(:user) }
  #   before(:each) do
  #     create(:state_in_progress)
  #     storage[:cart_items] = {}
  #     storage[:order_in_progress_id] = rand(1..10)
  #   end
  #   context 'when order is not persisted' do
  #     before { controller.instance_variable_set(:@order, build(:order)) }
  #     context 'when user is not loged in' do
  #       include_examples 'when order is not persisted'
  #     end
  #     context 'when user is loged in' do
  #       before do
  #         sign_in user
  #         allow(controller).to receive(:current_user).and_return(user)
  #       end
  #       include_examples 'when order is not persisted'
  #       it 'does not change user.order_in_progress and it is nil' do
  #         controller.send(:save_order_in_progress)
  #         expect(controller.current_user.order_in_progress).to be_nil
  #       end
  #     end
  #   end # 'when order is not persisted'
  #   context 'when order is persisted' do
  #     let(:order) { create(:order) }
  #     before { controller.instance_variable_set(:@order, order) }
  #     context 'when user is not loged in' do
  #       it 'sets storage[:cart_items] to nil' do
  #         controller.send(:save_order_in_progress)
  #         expect(storage[:cart_items]).to be_nil
  #       end
  #       it 'sets storage[:order_in_progress_id] to order.id' do
  #         controller.send(:save_order_in_progress)
  #         expect(storage[:order_in_progress_id]).to eq(order.id)
  #       end
  #     end
  #     context 'when user is loged in' do
  #       before do
  #         sign_in user
  #         allow(controller).to receive(:current_user).and_return(user)
  #       end
  #       it 'sets current_user.order_in_progress to order' do
  #         controller.send(:save_order_in_progress)
  #         expect(user.order_in_progress).to eq(order.reload)
  #       end
  #       it 'sets storage[:order_in_progress_id] to nil' do
  #         controller.send(:save_order_in_progress)
  #         expect(storage[:order_in_progress_id]).to be_nil
  #       end
  #       it 'sets storage[:cart_items] to nil' do
  #         controller.send(:save_order_in_progress)
  #         expect(storage[:cart_items]).to be_nil
  #       end
  #     end
  #   end # 'when order is persisted'
  # end # #save_order_in_progress

  describe '#define_order_in_progress' do
    it 'receive mathod #order of instance OrderFactory' do
      expect_any_instance_of(OrderFactory).to receive(:order).and_call_original
      controller.send(:define_order_in_progress)
    end
    it 'receive mathod #persist_strategy of instance OrderFactory' do
      expect_any_instance_of(OrderFactory).to receive(:persist_strategy).and_call_original
      controller.send(:define_order_in_progress)
    end
    it 'sets @order to instance Order' do
      controller.send(:define_order_in_progress)
      expect(assigns(:order)).to be_kind_of(Order)
    end
    it 'sets @order.persist_strategy to instance OrderStrategy::PersistBase' do
      controller.send(:define_order_in_progress)
      expect(assigns(:order).instance_variable_get(:@persist_strategy)).to be_kind_of(OrderStrategy::PersistBase)
    end
  end # #define_order_in_progress

  describe '#save_order_in_progress' do
    before(:each) { controller.instance_variable_set(:@order, create(:order)) }
    it 'receive mathod #keep_strategy of instance OrderFactory' do
      expect_any_instance_of(OrderFactory).to receive(:keep_strategy).and_call_original
      controller.send(:save_order_in_progress)
    end
    it 'sets @order.keep_strategy to instance OrderStrategy::PersistBase' do
      controller.send(:save_order_in_progress)
      expect(assigns(:order).instance_variable_get(:@keep_strategy)).to be_kind_of(OrderStrategy::KeepBase)
    end
    it 'receive mathod #order of instance OrderFactory' do
      expect(assigns(:order)).to receive(:keep_by_strategy).and_call_original
      controller.send(:save_order_in_progress)
    end
  end # #save_order_in_progress

  describe '#order_factory' do
    it 'returns instance OrderFactory' do
      expect(controller.send(:order_factory)).to be_kind_of(OrderFactory)
    end
  end # order_factory

end
