require 'rails_helper'

RSpec.describe User, type: :model do
  let(:session) { {} }
  before { allow_any_instance_of(Order).to receive(:session).and_return(session) }

  describe '#admin?' do
    context 'when user is admin' do
      it do
        user = create :user
        ENV['ADMIN_EMAIL'] = user.email
        expect(user.admin?).to be true
      end
    end

    context 'when user is not admin' do
      it do
        user = create :user
        ENV['ADMIN_EMAIL'] = FFaker::Internet.email
        expect(user.admin?).to be false
      end
    end
  end # #admin?

  describe '#order_in_progress' do
    let(:user) { create :user }

    context 'when user has order in progress' do
      let(:order) { create(:order_in_progress, user: user).reload }
      before { order }
      it "returns order in progress" do
        expect(user.order_in_progress).to be_eql(order)
      end
    end # when user has order in progress

    context 'when user does not have order in progress' do
      let(:order) { create(:order_in_queue, user: user).reload }
      before { order }
      it "returns order in progress" do
        expect(user.order_in_progress).to be_nil
      end
    end # when user does not have order in progress
  end # #order_in_progress

end
