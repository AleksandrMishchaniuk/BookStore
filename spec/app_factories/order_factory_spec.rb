require "rails_helper"

RSpec.describe OrderFactory do

  it { expect(described_class::STORAGE_KEY).to be_kind_of Symbol }
  it { expect(described_class::COUPON_STORAGE_KEY).to be_kind_of Symbol }
  it { expect(described_class::PERSISTED_KEY).to be_kind_of Symbol }
  it { expect(described_class::NOT_PERSISTED_KEY).to be_kind_of Symbol }
  it { expect(described_class::COUPON_KEY).to be_kind_of Symbol }

  let(:subject) { described_class.new(context) }
  let(:context) do
    object = double('instance ApplicationController')
    allow(object).to receive(:kind_of?).and_return(ApplicationController)
    # allow(object).to receive(:current_user)
    # allow(object).to receive(:user_signed_in?)
    object
  end

  describe '#initialize' do
    context "when passed argument is instance ApplicationController" do
      it "sets @context to passed argument" do
        expect(subject.instance_variable_get(:@context)).to eq(context)
      end
    end # when passed argument is instance ApplicationController

    context "when passed argument is not instance ApplicationController" do
      let(:context) { object = double('no instance ApplicationController') }
      it "raised RuntimeError" do
        expect{ subject }.to raise_error(RuntimeError)
      end
    end # when passed argument is instance ApplicationController
  end # #initialize

  describe '#order' do
    let(:user) { (create :user).reload }
    let(:order_keep_by_storage_persist) { create(:order).reload }
    let(:order_keep_by_user_persist) { create(:order_in_progress).reload }
    let(:order_keep_by_storage_not_persist) { build :order }
    let(:order_new) { Order.new }
    let(:storage){ {} }
    before(:each) do
      allow(subject).to receive(:order_storage).and_return(storage)
      storage[described_class::PERSISTED_KEY] = order_keep_by_storage_persist.id
      storage[described_class::NOT_PERSISTED_KEY] = order_keep_by_storage_not_persist.cart_items_to_array
      user.orders << order_keep_by_user_persist
      allow(subject).to receive(:current_user).and_return(user.reload)
      allow(subject).to receive(:user_signed_in?).and_return(true)
    end

    it "returns order_keep_by_storage_persist" do
      expect(subject.order).to eq(order_keep_by_storage_persist)
    end

    context "when storage with PERSISTED_KEY is nil" do
      before(:each) { storage[described_class::PERSISTED_KEY] = nil }
      it "returns order_keep_by_user_persist" do
        expect(subject.order).to eq(order_keep_by_user_persist.reload)
      end

      context "when user is not signed in" do
        before(:each){ allow(subject).to receive(:user_signed_in?).and_return(false) }
        it "returns order_keep_by_storage_not_persist" do
          expect(subject.order).to eq(order_keep_by_storage_not_persist)
        end

        context "when storage with NO_PERSISTED_KEY is nil" do
          before(:each) { storage[described_class::NOT_PERSISTED_KEY] = nil }
          it "returns order_keep_by_user_persist" do
            expect(subject.order).to eq(order_new)
          end
        end # when storage with NO_PERSISTED_KEY is nil
      end # when user is not signed in

      context "when user does not have order in progress" do
        before(:each) { order_keep_by_user_persist.update(user_id: nil) }
        it "returns order_keep_by_storage_not_persist" do
          expect(subject.order).to eq(order_keep_by_storage_not_persist)
        end

        context "when storage with NO_PERSISTED_KEY is nil" do
          before(:each) { storage[described_class::NOT_PERSISTED_KEY] = nil }
          it "returns order_keep_by_user_persist" do
            expect(subject.order).to eq(order_new)
          end
        end # when storage with NO_PERSISTED_KEY is nil
      end # when user does not have order in progress
    end # when storage with PERSISTED_KEY is nil
  end # #order

  describe '#persist_strategy' do
    before do
      coupon_storage = double('instance Storage')
      allow(coupon_storage).to receive(:kind_of?).and_return(Storage)
      allow(subject).to receive(:coupon_storage).and_return(coupon_storage)
      order_storage = double('instance Storage')
      allow(order_storage).to receive(:kind_of?).and_return(Storage)
      allow(subject).to receive(:order_storage).and_return(order_storage)
    end

    context 'when passed no instance Order' do
      it "raise RuntimeError" do
        expect{ subject.persist_strategy('some object') }.to raise_error(RuntimeError)
      end
    end # when passed no instance Order

    context 'when passed persisted order' do
      let(:order) { create :order }
      it "returns instance OrderStrategy::PersistByDb" do
        expect(subject.persist_strategy(order)).to be_kind_of(OrderStrategy::PersistByDb)
      end
    end # when passed persisted order

    context 'when passed not persisted order' do
      let(:order) { build :order }
      it "returns instance OrderStrategy::PersistByStorage" do
        expect(subject.persist_strategy(order)).to be_kind_of(OrderStrategy::PersistByStorage)
      end
    end # when passed not persisted order
  end # #persist_strategy


  describe '#keep_strategy' do
    let(:user){ create :user }
    before do
      order_storage = double('instance Storage')
      allow(order_storage).to receive(:kind_of?).and_return(Storage)
      allow(subject).to receive(:order_storage).and_return(order_storage)
      allow(subject).to receive(:current_user).and_return(user)
      # allow(subject).to receive(:user_signed_in?).and_return(true)
    end

    context 'when passed no instance Order' do
      it "raise RuntimeError" do
        expect{ subject.keep_strategy('some object') }.to raise_error(RuntimeError)
      end
    end # when passed no instance Order

    context 'when order is persisted' do
      let(:order) { create :order }
      context 'when user is signed in' do
        before { allow(subject).to receive(:user_signed_in?).and_return(true) }
        it "returns instance OrderStrategy::KeepByUser" do
          expect(subject.keep_strategy(order)).to be_kind_of(OrderStrategy::KeepByUser)
        end
      end # when user is signed in

      context 'when user is not signed in' do
        before { allow(subject).to receive(:user_signed_in?).and_return(false) }
        it "returns instance OrderStrategy::KeepByStoragePersist" do
          expect(subject.keep_strategy(order)).to be_kind_of(OrderStrategy::KeepByStoragePersist)
        end
      end # when user is not signed in
    end # when order is persisted

    context 'when order is not persisted' do
      let(:order) { build :order }
      it "returns instance OrderStrategy::KeepByStorageNotPersist" do
        expect(subject.keep_strategy(order)).to be_kind_of(OrderStrategy::KeepByStorageNotPersist)
      end
    end # when order is not persisted
  end # #keep_strategy

  describe '#order_storage' do
    before { allow(context).to receive(:session).and_return({}) }
    it "returns instance Storage" do
      expect(subject.send(:order_storage)).to be_kind_of(Storage)
    end
  end # #order_storage

  describe '#coupon_storage' do
    before { allow(context).to receive(:session).and_return({}) }
    it "returns instance Storage" do
      expect(subject.send(:coupon_storage)).to be_kind_of(Storage)
    end
  end # #coupon_storage

  describe '#current_user' do
    it "calls #current_user on @context" do
      expect(context).to receive(:current_user)
      subject.send(:current_user)
    end
  end # #current_user

  describe '#user_signed_in?' do
    it "calls #user_signed_in? on @context" do
      expect(context).to receive(:user_signed_in?)
      subject.send(:user_signed_in?)
    end
  end # #user_signed_in?

end
