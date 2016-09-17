require 'rails_helper'

RSpec.describe Order, type: :model do

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

    before { allow(order).to receive(:coupon_by_strategy).and_return(order.coupon) }

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

end
