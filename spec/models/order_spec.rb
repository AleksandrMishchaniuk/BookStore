require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:session) { {} }
  before { allow_any_instance_of(described_class).to receive(:session).and_return(session) }

  context 'order price methods' do
    let(:book_1) { create(:book, price: 2.5) }
    let(:book_2) { create(:book, price: 3.5) }
    let(:book_3) { create(:book, price: 2.0) }
    let(:count_1) { 2 }
    let(:count_2) { 2 }
    let(:count_3) { 4 }
    let(:order) do
      order = build :order
      default_items = order.carts
      create(:cart, order: order, book: book_1, book_count: count_1)
      create(:cart, order: order, book: book_2, book_count: count_2)
      create(:cart, order: order, book: book_3, book_count: count_3)
      create(:coupon, order: order, discount: 0.1)
      default_items.each &:destroy
      order.save!
      order.reload
    end

    describe '#item_total' do
      it { expect(order.item_total).to be_eql(20.0) }
    end

    describe '#item_discount' do
      it { expect(order.item_discount).to be_eql(2.0) }
    end

    describe '#item_total_with_discount' do
      it { expect(order.item_total_with_discount).to be_eql(18.0) }
    end

    describe '#order_total' do
      context 'when delivery is set' do
        before { order.delivery = create(:delivery, price: 10.0) }
        it { expect(order.order_total).to be_eql(28.0) }
      end
      context 'when delivery is not set' do
        it { expect(order.order_total).to be_eql(18.0) }
      end
    end
  end # order price methods

  context 'order persist methods' do
    let(:order) { create :order }

    describe '#save_with_cart_items' do
      context 'when user try to change book count in cart item' do

        it 'changes cart item' do
          old_count = order.carts[0].book_count
          new_count = old_count + 2
          order.carts[0].book_count = new_count
          order.save_with_cart_items
          order.reload
          expect(order.carts[0].book_count).to eq(new_count)
        end

        context 'when use #save instead #save_with_cart_items' do
          it 'does not change cart item' do
            old_count = order.carts[0].book_count
            new_count = old_count + 2
            order.carts[0].book_count = new_count
            order.save
            order.reload
            expect(order.carts[0].book_count).to eq(old_count)
          end
        end # when use #save method

      end # when user rty to change book count in cart item
    end # #save_with_cart_items
  end # order persist methods

  describe '#coupon' do
    context 'when order is persisted' do
      let(:order) { create :order }
      it 'does not get coupon from session' do
        expect(order).to_not receive(:get_coupon_from_session)
        order.coupon
      end
    end
    context 'when order is not persisted' do
      let(:order) { build :order }
      it 'get coupon from session' do
        expect(order).to receive(:get_coupon_from_session)
        order.coupon
      end
    end
  end # #coupon

  describe '#coupon=' do
    let(:order) { create :order }
    let(:new_coupon){ create :coupon }
    let(:old_coupon) { create(:coupon, order: order) }

    it do
      expect(order).to receive(:detach_coupon)
      expect(new_coupon).to receive(:attach)
      order.coupon = new_coupon
    end

    context 'when passed Nil object' do
      before { old_coupon }
      it do
        expect(order).to receive(:detach_coupon)
        expect_any_instance_of(Coupon).to_not receive(:attach)
        order.coupon = nil
      end
    end

    context 'when passed no Coupon or no Nil object' do
      it 'raises error' do
        expect{order.coupon = 'string'}.to raise_error(RuntimeError)
        expect{order.coupon = 23.4}.to raise_error(RuntimeError)
        expect{order.coupon = {a: 'a', b: 'b'}}.to raise_error(RuntimeError)
      end
    end # when passed not Coupon or Nil object

    context 'when order is persisted' do
      it 'does not save coupon to session' do
        expect(order).to_not receive(:save_coupon_to_session)
        order.coupon = new_coupon
      end
    end # when order is persisted
    context 'when order is not persisted' do
      let(:order) { build :order }
      it 'does not save coupon to session' do
        expect(order).to receive(:save_coupon_to_session)
        order.coupon = new_coupon
      end
    end # when order is not persisted
  end # #coupon=

  describe '#detach_coupon' do
    let(:order) { create :order }
    it 'deletes coupon from session' do
      expect(order).to receive(:clear_coupon_in_session)
      order.detach_coupon
    end
    context 'when order has coupon' do
      before do
        create(:coupon, order: order)
      end
      it 'makes coupon free for use' do
        expect(order.coupon).to receive(:detach)
        order.detach_coupon
      end
    end
  end # #detach_coupon

  describe '#save_coupon_to_session' do
    let(:order) { build :order }
    let(:coupon) { create :coupon }
    let(:old_coupon) { create :coupon }
    before { session[:coupon_id] = old_coupon.id }

    context 'when passed Coupon object' do
      it 'sets coupon id in session to new coupon id' do
        expect{ order.send(:save_coupon_to_session, coupon) }
                      .to change{ session[:coupon_id] }
                      .from(old_coupon.id)
                      .to(coupon.id)
      end
    end # sets coupon id in session to new coupon id

    context 'when passed Nil object' do
      it 'sets coupon id in session to nil' do
        expect{ order.send(:save_coupon_to_session, nil) }
                      .to change{ session[:coupon_id] }
                      .from(old_coupon.id)
                      .to(nil)
      end
    end # when passed Nil object
  end # #save_coupon_to_session

  describe '#get_coupon_from_session' do
    let(:order) { build :order }
    let(:coupon) { create(:coupon).reload }

    context 'when coupon id sets in session' do
      before { session[:coupon_id] = coupon.id }
      it 'returns Coupon object' do
        expect(order.send(:get_coupon_from_session)).to be_eql(coupon)
      end
    end # when coupon id sets in session

    context 'when coupon id does not set in session' do
      before { session[:coupon_id] = nil }
      it 'returns nil' do
        expect(order.send(:get_coupon_from_session)).to be_eql(nil)
      end
    end # when coupon id does not set in session
  end # #get_coupon_from_session

  describe '#set_coupon_after_save' do
    let(:order) { create :order }
    let(:coupon) { create(:coupon).reload }

    context 'when coupon id sets in session' do
      before do
        order.coupon = nil
        session[:coupon_id] = coupon.id
      end
      it 'sets coupon id in session to nil' do
        expect(order).to receive(:clear_coupon_in_session)
        order.send(:set_coupon_after_save)
      end
      it 'sets coupon for order from session' do
        order.send(:set_coupon_after_save)
        expect(order.coupon).to be_eql(coupon)
      end
    end # when coupon id sets in session
  end # #set_coupon_after_save

end
