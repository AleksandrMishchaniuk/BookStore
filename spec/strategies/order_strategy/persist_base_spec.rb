require "rails_helper"

RSpec.describe OrderStrategy::PersistBase do

  subject { described_class.new(coupon_storage, coupon_key) }
  let(:coupon_key) { :coupon_key }
  let(:coupon_storage) do
    object = {}
    allow(object).to receive(:is_a?).with(Storage).and_return(true)
    object
  end

  describe '#initialize' do
    context "when passed write arguments" do
      it "sets @coupon_storage to passed argument" do
        expect(subject.instance_variable_get(:@coupon_storage)).to eq(coupon_storage)
      end
      it "sets @coupon_key to passed argument" do
        expect(subject.instance_variable_get(:@coupon_key)).to eq(coupon_key)
      end
    end # when passed write arguments

    context "when passed argument #1 is not instance Storage" do
      let(:coupon_storage) { double('no instance Storage') }
      it "raised RuntimeError" do
        expect{ subject }.to raise_error(RuntimeError)
      end
    end # when passed argument #1 is instance Storage

    context "when passed argument #2 is not instance Symbol" do
      let(:coupon_key) { double('no instance Symbol') }
      it "raised RuntimeError" do
        expect{ subject }.to raise_error(RuntimeError)
      end
    end # when passed argument #1 is instance Symbol
  end # #initialize

  describe '#save' do
    it "raise RuntimeError" do
      expect{subject.save('some object')}.to raise_error(RuntimeError)
    end
  end # #save

  describe '#destroy' do
    it "raise RuntimeError" do
      expect{subject.destroy('some object')}.to raise_error(RuntimeError)
    end
  end # #destroy

  describe '#set_coupon' do
    it "raise RuntimeError" do
      expect{subject.set_coupon('some object')}.to raise_error(RuntimeError)
    end
  end # #set_coupon

  describe '#get_coupon' do
    it "raise RuntimeError" do
      expect{subject.get_coupon('some object')}.to raise_error(RuntimeError)
    end
  end # #get_coupon

  describe '#prepare' do
    context 'when passed argument is not instance Order' do
      it "raised RuntimeError" do
        expect{ subject.send(:prepare, 'some object') }.to raise_error(RuntimeError)
      end
    end # when passed argument is not instance Order
  end # #prepare_keep

  describe '#prepare_destroy' do
    let(:order){ build :order }
    it "calls #prepare" do
      expect(subject).to receive(:prepare).with(order)
      subject.send(:prepare_destroy, order)
    end
    it "calls #detach_coupon" do
      expect(subject).to receive(:detach_coupon).with(order)
      subject.send(:prepare_destroy, order)
    end
  end # #prepare_destroy

  describe '#prepare_set_coupon' do
    let(:order){ build :order }
    let(:coupon){ build :coupon }

    context 'when passed argument #2 is not instance Coupon or nil' do
      let(:no_coupon) { double('no instance Coupon') }
      it "raised RuntimeError" do
        expect{ subject.send(:prepare_set_coupon, order, no_coupon) }.to raise_error(RuntimeError)
      end
    end # when passed argument #2 is not instance Coupon

    it "calls #detach_coupon" do
      expect(subject).to receive(:detach_coupon).with(order)
      subject.send(:prepare_set_coupon, order, coupon)
    end

    context 'when argument #2 is instance Coupon' do
      it "calls #attach for coupon" do
        expect(coupon).to receive(:attach)
        subject.send(:prepare_set_coupon, order, coupon)
      end
    end # when argument #2 is instance Coupon
    context 'when argument #2 is instance nil' do
      it "does not call #attach for coupon" do
        expect(coupon).to_not receive(:attach)
        subject.send(:prepare_set_coupon, order, nil)
      end
    end # when argument #2 is instance nil
  end # #prepare_set_coupon

  describe '#detach_coupon' do
    let(:order) { build :order }
    context 'when passed argument is not instance Order' do
      it "raised RuntimeError" do
        expect{ subject.send(:detach_coupon, 'some object') }.to raise_error(RuntimeError)
      end
    end # when passed argument is not instance Order

    context 'when order has coupon' do
      before { allow(order).to receive(:coupon_by_strategy).and_return(build :coupon) }
      it "calls #detach for order's coupon" do
        expect(order.coupon_by_strategy).to receive(:detach)
        subject.send(:detach_coupon, order)
      end
    end # when order has coupon

    context 'when order has not coupon' do
      before { allow(order).to receive(:coupon_by_strategy).and_return(nil) }
      it "does not call #detach for order's coupon" do
        allow_message_expectations_on_nil
        expect(order.coupon_by_strategy).to_not receive(:detach)
        subject.send(:detach_coupon, order)
      end
    end # when order has coupon

    it "sets coupon in storage to nil" do
      coupon_storage[coupon_key] = rand(1..10)
      subject.send(:detach_coupon, order)
      expect(coupon_storage[coupon_key]).to be_nil
    end
  end # #detach_coupon

end
