require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  include OdrderInProgressHelpers

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
