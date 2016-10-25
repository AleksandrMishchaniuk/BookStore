require "rails_helper"

RSpec.describe OrderStrategy::PersistByDb do

  subject { described_class.new(coupon_storage, coupon_key) }
  let(:coupon_key) { :coupon_key }
  let(:coupon_storage) do
    object = {}
    allow(object).to receive(:is_a?).with(Storage).and_return(true)
    object
  end
  let(:order) { create :order }

  describe '#save' do
    after(:each) { subject.save(order) }
    it "calls #prepare" do
      expect(subject).to receive(:prepare).with(order)
    end
    it "calls #save_with_cart_items for order" do
      expect(order).to receive(:save_with_cart_items)
    end
  end # #save

  describe '#destroy' do
    after(:each) { subject.destroy(order) }
    it "calls #prepare_destroy" do
      expect(subject).to receive(:prepare_destroy).with(order)
    end
    it "calls #destroy! for order" do
      expect(order).to receive(:destroy!).and_call_original
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
    it "calls #check_coupon_storage" do
      expect(subject).to receive(:check_coupon_storage).with(order)
      subject.get_coupon(order)
    end
    it "returns order's coupon" do
      coupon
      order.reload
      expect(subject.get_coupon(order)).to eq(coupon)
    end
  end # #get_coupon

  describe '#set_coupon' do
    let(:coupon) { create :coupon }
    it "calls #prepare" do
      expect(subject).to receive(:prepare).with(order)
      subject.set_coupon(order, coupon)
    end
    it "calls #check_coupon_storage" do
      expect(subject).to receive(:check_coupon_storage).with(order)
      subject.set_coupon(order, coupon)
    end
    context 'when order already has coupon same as passed coupon' do
      before(:each) { order.coupon = coupon }
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
    it "sets order's coupon to passed coupon" do
      subject.set_coupon(order, coupon)
      expect(order.coupon).to eq(coupon)
    end
  end # #set_coupon


  describe '#check_coupon_storage' do
    let(:coupon) { create :coupon }

    context 'when coupon in storage set to nil' do
      before { coupon_storage[coupon_key] = nil }
      it "does not change order's coupon" do
        expect{subject.send(:check_coupon_storage, order)}.to_not change{order.coupon}
      end
    end # when coupon in storage set to nil

    context 'when coupon in storage set to some coupon' do
      before { coupon_storage[coupon_key] = coupon.id }
      it "changes order's coupon" do
        expect{subject.send(:check_coupon_storage, order)}.to change{order.coupon}.to(coupon)
      end
      it "sets coupon in storage to nil" do
        subject.send(:check_coupon_storage, order)
        expect(coupon_storage[coupon_key]).to be_nil
      end
    end # when coupon in storage set to some coupon
  end # #check_coupon_storage

end
