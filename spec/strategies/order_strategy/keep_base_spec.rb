require "rails_helper"

RSpec.describe OrderStrategy::KeepBase do

  subject { described_class.new(storage) }
  let(:storage) do
    object = {}
    allow(object).to receive(:kind_of?).with(Storage).and_return(true)
    object
  end

  describe '#initialize' do
    context "when passed argument is instance Storage" do
      it "sets @storage to passed argument" do
        expect(subject.instance_variable_get(:@storage)).to eq(storage)
      end
    end # when passed argument is instance Storage

    context "when passed argument is not instance Storage" do
      let(:storage) { double('no instance Storage') }
      it "raised RuntimeError" do
        expect{ subject }.to raise_error(RuntimeError)
      end
    end # when passed argument is instance Storage
  end # #initialize

  describe '#keep' do
    it "raise RuntimeError" do
      expect{subject.keep('some object')}.to raise_error(RuntimeError)
    end
  end # #keep

  describe '#prepare_keep' do
    context 'when passed argument is not instance Order' do
      it "raised RuntimeError" do
        expect{ subject.prepare_keep('some object') }.to raise_error(RuntimeError)
      end
    end # when passed argument is not instance Order
    context 'when passed argument is instance Order' do
      it "calls #clear for @storage" do
        expect(storage).to receive(:clear)
        subject.prepare_keep(build :order)
      end
    end # when passed argument is instance Order
  end # #prepare_keep

end
