require "rails_helper"

RSpec.describe OrderStrategy::KeepByUser do

  subject { described_class.new(storage, user) }
  let(:user) { create :user }
  let(:storage) do
    object = {}
    allow(object).to receive(:kind_of?).with(Storage).and_return(true)
    object
  end

  describe '#initialize' do
    context "when second passed argument is instance User" do
      it "sets @user to passed argument" do
        expect(subject.instance_variable_get(:@user)).to eq(user)
      end
    end # when second passed argument is instance User

    context "when second passed argument is not instance User" do
      let(:user) { double('no instance User') }
      it "raised RuntimeError" do
        expect{ subject }.to raise_error(RuntimeError)
      end
    end # when second passed argument is not instance User
  end # #initialize

  describe '#keep' do
    let(:order) { create :order }
    it "calls #prepare_keep" do
      expect(subject).to receive(:prepare_keep).with(order)
      subject.keep(order)
    end
    it "sets order's user" do
      subject.keep(order)
      expect(order.user).to eq(user)
    end
  end # #keep

end
