require "rails_helper"

RSpec.describe OrderStrategy::KeepByStorageNotPersist do

  subject { described_class.new(storage, key) }
  let(:key) { :some_key }
  let(:storage) do
    object = {}
    allow(object).to receive(:is_a?).with(Storage).and_return(true)
    object
  end

  describe '#initialize' do
    context "when second passed argument is instance Symbol" do
      it "sets @key to passed argument" do
        expect(subject.instance_variable_get(:@key)).to eq(key)
      end
    end # when second passed argument is instance Symbol

    context "when second passed argument is not instance Symbol" do
      let(:key) { double('no instance Symbol') }
      it "raised RuntimeError" do
        expect{ subject }.to raise_error(RuntimeError)
      end
    end # when second passed argument is not instance Symbol
  end # #initialize

  describe '#keep' do
    let(:order) { create :order }
    it "calls #prepare_keep" do
      expect(subject).to receive(:prepare_keep).with(order)
      subject.keep(order)
    end
    it "seves order cart_items to storage" do
      subject.keep(order)
      expect(storage[key]).to eq(order.cart_items_to_array)
    end
  end # #keep

end
