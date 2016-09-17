require 'rails_helper'

RSpec.describe User, type: :model do

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

  describe '#data' do
    let(:user) { create :user }

    context 'when user has soc_auths with filling data' do
      let(:data) do
        [
          { n1: 'A1',   n2: 'B1',   n3: nil,    n4: nil },
          { n1: nil,    n2: nil,    n3: nil,    n4: nil },
          { n1: nil,    n2: 'B3',   n3: 'C3',   n4: nil }
        ]
      end
      let(:exp_data) { { n1: 'A1',   n2: 'B1',   n3: 'C3' } }
      before { 3.times.map{ |i| create :soc_auth, user: user, data: data[i] } }
      it "merges all soc_auths datas" do
        expect(user.data).to be_eql(exp_data)
      end
    end # when user has soc_auth with filling data

    context 'when user has soc_auth without data' do
      before { 3.times.map{ create :soc_auth, user: user, data: nil } }
      it "returns empty hash" do
        expect(user.data).to be_kind_of(Hash)
        expect(user.data).to be_empty
      end
    end # when user has soc_auth with filling data

    context 'when user does not have soc_auths' do
      it "returns nil" do
        expect(user.data).to be_nil
      end
    end # when user has soc_auth with filling data

  end # #data

end
