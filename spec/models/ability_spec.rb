require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability, type: :model do

  subject { Ability.new(user) }
  before(:each) do
    request = double('Request')
    allow(described_class).to receive(:request).and_return(request)
    allow(request).to receive(:original_fullpath).and_return('/admin')
  end

  context 'when user is loged in' do
    let(:user) { create :user }
    it { expect(subject).to be_able_to(:create, Review.new) }
    it { expect(subject).to be_able_to(:read, Order.new(user_id: user.id)) }
    it { expect(subject).to_not be_able_to(:read, Order.new) }

    context 'when user is not admin' do
      it { expect(subject).to_not be_able_to(:access, :rails_admin) }
      it { expect(subject).to_not be_able_to(:dashboard, nil) }
    end # when user is not admin

    context 'when user is admin' do
      let(:user) { create(:admin) }
      it { expect(subject).to be_able_to(:access, :rails_admin) }
      it { expect(subject).to be_able_to(:dashboard, nil) }
    end # when user is admin
  end # when user is loged in

  context 'when user is not loged in' do
    let(:user){ nil }
    it { expect(subject).to_not be_able_to(:create, Review.new) }
  end # when user is not loged in

end
