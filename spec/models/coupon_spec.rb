require "rails_helper"

RSpec.describe Coupon, type: :model do

  describe '#attach' do
    context 'when coupon already is used' do
      let(:coupon) {create(:coupon, used: true)}
      it "does not update attribute :used" do
        expect(coupon).to receive(:used).and_call_original
        expect(coupon).to_not receive(:update_attributes)
        coupon.attach
      end
    end # when coupon already used
    context 'when coupon is not used' do
      let(:coupon) {create(:coupon, used: false)}
      it "does not update attribute :used" do
        expect(coupon).to receive(:used).and_call_original
        expect(coupon).to receive(:update_attributes).with({used: true})
        coupon.attach
      end
    end # when coupon is not used
  end # #attach

  describe '#detach' do
    let(:coupon) {create(:coupon, used: true)}
    it "sets used to false and order_id to nil" do
      expect(coupon).to receive(:update_attributes).with({used: false, order_id: nil})
      coupon.detach
    end
  end  # #detach

end
