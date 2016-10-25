require "rails_helper"

RSpec.describe OrderStrategy::PersistByStorage do

  subject { described_class.new(coupon_storage, coupon_key, order_storage, order_key) }
  let(:coupon_key) { :coupon_key }
  let(:order_key) { :order_key }
  let(:coupon_storage) do
    object = {}
    allow(object).to receive(:is_a?).with(Storage).and_return(true)
    object
  end
  let(:order_storage){ coupon_storage.clone }

  let(:order) { build :order }

  describe '#initialize' do
    context "when passed write arguments" do
      it "sets @order_storage to passed argument" do
        expect(subject.instance_variable_get(:@order_storage)).to eq(order_storage)
      end
      it "sets @order_key to passed argument" do
        expect(subject.instance_variable_get(:@order_key)).to eq(order_key)
      end
    end # when passed write arguments

    context "when passed argument #3 is not instance Storage" do
      let(:order_storage) { double('no instance Storage') }
      it "raised RuntimeError" do
        expect{ subject }.to raise_error(RuntimeError)
      end
    end # when passed argument #1 is instance Storage

    context "when passed argument #2 is not instance Symbol" do
      let(:order_key) { double('no instance Symbol') }
      it "raised RuntimeError" do
        expect{ subject }.to raise_error(RuntimeError)
      end
    end # when passed argument #1 is instance Symbol
  end # #initialize


  describe '#save' do
    it "calls #prepare" do
      expect(subject).to receive(:prepare).with(order)
      subject.save(order)
    end
    it "sets order in storage to arrey of order items hashes" do
      subject.save(order)
      expect(order_storage[order_key]).to eq(order.cart_items_to_array)
    end
  end # #save

  describe '#destroy' do
    after(:each) { subject.destroy(order) }
    it "calls #prepare_destroy" do
      expect(subject).to receive(:prepare_destroy).with(order)
    end
    it "calls #delete_all for order's cart_items collection" do
      expect(order.cart_items).to receive(:delete_all).and_call_original
    end
  end # #destroy

  describe '#get_coupon' do
    let(:coupon) { create(:coupon, order: order) }
    it "calls #prepare" do
      expect(subject).to receive(:prepare).with(order)
      subject.get_coupon(order)
    end
    context 'when storage has coupon' do
      before { coupon_storage[coupon_key] = coupon.id }
      it "returns coupon from storage" do
        expect(subject.get_coupon(order)).to eq(coupon)
      end
    end # when storage has coupon
    context 'when storage does not have coupon' do
      before { coupon_storage[coupon_key] = nil }
      it "returns nil" do
        expect(subject.get_coupon(order)).to be_nil
      end
    end # when storage does not have coupon
  end # #get_coupon

  describe '#set_coupon' do
    let(:coupon) { create :coupon }
    it "calls #prepare" do
      expect(subject).to receive(:prepare).with(order)
      subject.set_coupon(order, coupon)
    end
    context 'when order already has coupon same as passed coupon' do
      before(:each) do
        coupon_storage[coupon_key] = coupon.id
        order.persist_strategy = subject
      end
      it "returns coupon" do
        expect(subject.set_coupon(order, coupon)).to eq(coupon)
      end
      it "does not call #prepare_set_coupon" do
        expect(subject).to_not receive(:prepare_set_coupon)
        subject.set_coupon(order, coupon)
      end
    end # when order has coupon same as passed coupon
    it "calls #prepare_set_coupon" do
      expect(subject).to receive(:prepare_set_coupon).with(order, coupon)
      subject.set_coupon(order, coupon)
    end
    it "sets coupon in storage to passed coupon" do
      subject.set_coupon(order, coupon)
      expect(coupon_storage[coupon_key]).to eq(coupon.id)
    end
  end # #set_coupon

end
