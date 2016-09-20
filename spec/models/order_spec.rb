require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:order) { create :order }

  it "sets order_state to in_progress for new created order" do
    state = create :state_in_progress
    expect(order.order_state).to eq(state)
  end

  it "destroys binded objects after destruction order" do
    expect(order).to receive(:destroy_binded_objects)
    order.destroy!
  end

  it "calls #destroys cart_items before destruction order" do
    expect(order).to receive(:destroy_cart_items)
    order.destroy!
  end

  describe '#persist_strategy=' do
    context 'when passed no instance OrderStrategy::PersistBase' do
      let(:val) { 'some object' }
      it "raises exception" do
        expect { order.persist_strategy = val }.to raise_error(RuntimeError)
      end
    end # when passed no instance OrderStrategy::PersistBase
    context 'when passed instance OrderStrategy::PersistBase' do
      let(:val) { double 'instance OrderStrategy::PersistBase' }
      before { allow(val).to receive(:kind_of?).and_return(OrderStrategy::PersistBase) }
      it "sets @persist_strategy" do
        order.persist_strategy = val
        variable = order.instance_variable_get(:@persist_strategy)
        expect(variable).to be_kind_of(OrderStrategy::PersistBase)
      end
    end # when passed instance OrderStrategy::PersistBase
  end # #persist_strategy=

  describe '#keep_strategy=' do
    context 'when passed no instance OrderStrategy::KeepBase' do
      let(:val) { 'some object' }
      it "raises exception" do
        expect { order.keep_strategy = val }.to raise_error(RuntimeError)
      end
    end # when passed no instance OrderStrategy::KeepBase
    context 'when passed instance OrderStrategy::KeepBase' do
      let(:val) { double 'instance OrderStrategy::KeepBase' }
      before { allow(val).to receive(:kind_of?).and_return(OrderStrategy::KeepBase) }
      it "sets @keep_strategy" do
        order.keep_strategy = val
        variable = order.instance_variable_get(:@keep_strategy)
        expect(variable).to be_kind_of(OrderStrategy::KeepBase)
      end
    end # when passed instance OrderStrategy::KeepBase
  end # #keep_strategy=

  describe '#keep_by_strategy' do
    let(:keep_strategy) { double 'instance OrderStrategy::KeepBase' }
    before { order.instance_variable_set(:@keep_strategy, keep_strategy) }
    it "calls #keep on @keep_strategy" do
      expect(keep_strategy).to receive(:keep).with(order)
      order.keep_by_strategy
    end
  end # #keep_by_strategy

  describe '#save_by_strategy' do
    let(:persist_strategy) { double 'instance OrderStrategy::PersistBase' }
    before { order.instance_variable_set(:@persist_strategy, persist_strategy) }
    it "calls #save on @persist_strategy" do
      expect(persist_strategy).to receive(:save).with(order)
      order.save_by_strategy
    end
  end # #save_by_strategy

  describe '#destroy_by_strategy' do
    let(:persist_strategy) { double 'instance OrderStrategy::PersistBase' }
    before { order.instance_variable_set(:@persist_strategy, persist_strategy) }
    it "calls #destroy on @persist_strategy" do
      expect(persist_strategy).to receive(:destroy).with(order)
      order.destroy_by_strategy
    end
  end # #destroy_by_strategy

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

  describe '#number' do
    it "returns instance String" do
      expect(order.number).to be_kind_of(String)
    end
  end # #number

  describe '#cart_items_to_array' do
    it "returns array of hashes with cart_items parameters" do
      array = order.cart_items_to_array
      expect(array).to be_kind_of(Array)
      array.each_with_index do |val, i|
        expect(order.cart_items[i].attributes).to eq(val)
      end
    end
  end # #cart_items_to_array

  describe '#find_or_build_cart_item' do
    context 'when book already is in cart' do
      let(:cart_item) { order.cart_items[rand(0...order.cart_items.size)] }
      it "returns cart item with this book" do
        expect(order.find_or_build_cart_item(cart_item.book_id)).to eq(cart_item)
      end
    end # when book already in cart
    context 'when book is not in cart' do
      let(:book) { create :book }
      it "returns new not persisted cart item" do
        expect(order.find_or_build_cart_item(book.id)).to be_kind_of(Cart)
        expect(order.find_or_build_cart_item(book.id)).to_not be_persisted
      end
      it "returns cart iten with this book and count 0" do
        expect(order.find_or_build_cart_item(book.id).book_id).to eq(book.id)
        expect(order.find_or_build_cart_item(book.id).book_count).to eq(0)
      end
    end # when book already in cart
  end # #find_or_build_cart_item

  describe '#cart_item' do
    context 'when book already is in cart' do
      let(:cart_item) { order.cart_items[rand(0...order.cart_items.size)] }
      it "returns cart item with this book" do
        expect(order.cart_item(cart_item.book_id)).to eq(cart_item)
      end
    end # when book already in cart
    context 'when book is not in cart' do
      let(:book) { create :book }
      it "returns new not persisted cart item" do
        expect(order.cart_item(book.id)).to be_nil
      end
    end # when book already in cart
  end # #cart_item

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

  describe '#destroy_binded_objects' do
    let(:billing_address) { create :address }
    let(:shipping_address) { create :address }
    let(:credit_card) { create :credit_card }
    before(:each) do
      order.billing_address = billing_address
      order.shipping_address = shipping_address
      order.shipping_address = shipping_address
      order.credit_card = credit_card
    end
    it "destroys order's adresses and credit cats" do
      order.destroy_binded_objects
      expect(billing_address).to_not be_persisted
      expect(shipping_address).to_not be_persisted
      expect(credit_card).to_not be_persisted
    end
  end # #destroy_binded_objects

  describe '#destroy_cart_items' do
    it "destroys cart_items in DB" do
      order.destroy_cart_items
      order.cart_items.each do |item|
        expect(item).to_not be_persisted
      end
    end
  end # #destroy_cart_items

  describe '#set_coupon' do
    before { allow(order).to receive(:coupon_by_strategy=) }

    context "when passed existing coupon and it is not used" do
      let(:coupon) { create :coupon, used: false }
      it "calls #coupon_by_strategy= method" do
        expect(order).to receive(:coupon_by_strategy=).with(coupon)
        order.set_coupon(coupon)
      end
      it "returns self" do
        expect(order.set_coupon(coupon)).to eq(order)
      end
    end # when coupon exist and don't used

    context "when passed nil" do
      it "calls #coupon_by_strategy= method" do
        expect(order).to receive(:coupon_by_strategy=).with(nil)
        order.set_coupon(nil)
      end
      it "returns self" do
        expect(order.set_coupon(nil)).to eq(false)
      end
    end # when passed nil

    context "when passed already used coupon, but don't bind with current order" do
      let(:coupon) { create :coupon, used: true }
      it "calls #coupon_by_strategy= method" do
        expect(order).to receive(:coupon_by_strategy=).with(nil)
        order.set_coupon(coupon)
      end
      it "returns self" do
        expect(order.set_coupon(coupon)).to eq(false)
      end
    end # when passed already used coupon, but don't bind with current order

    context "when passed already used coupon and binded with current order" do
      let(:coupon) { create :coupon, used: true }
      before { allow(order).to receive(:coupon_by_strategy).and_return(coupon) }
      it "calls #coupon_by_strategy= method" do
        expect(order).to_not receive(:coupon_by_strategy=)
        order.set_coupon(coupon)
      end
      it "returns self" do
        expect(order.set_coupon(coupon)).to eq(order)
      end
    end # when passed already used coupon and binded with current order
  end # #set_coupon

  describe '#coupon_by_strategy' do
    let(:coupon){ create :coupon }
    let(:persist_strategy){ double("instance OrderStrategy::PersistBase") }
    before(:each) { order.instance_variable_set(:@persist_strategy, persist_strategy) }

    context "when @persist_strategy seted as instance OrderStrategy::PersistBase" do
      before(:each) { allow(persist_strategy).to receive(:get_coupon).with(order).and_return(coupon) }
      it "calls #get_coupon for @persist_strategy" do
        expect(persist_strategy).to receive(:try).with(:get_coupon, order).and_return(coupon)
        order.coupon_by_strategy
      end
      it "returns coupon" do
        expect(order.coupon_by_strategy).to eq(coupon)
      end
    end # when @persist_strategy seted as instance OrderStrategy::PersistBase

    context "when @persist_strategy didn't set as instance OrderStrategy::PersistBase" do
      before(:each) { order.coupon = coupon }
      it "does not call #get_coupon for @persist_strategy" do
        expect(persist_strategy).to receive(:try).with(:get_coupon, order).and_return(nil)
        order.coupon_by_strategy
      end
      it "calls #coupon" do
        expect(order).to receive(:coupon).and_return(coupon)
        order.coupon_by_strategy
      end
      it "returns coupon" do
        expect(order.coupon_by_strategy).to eq(coupon)
      end
    end # when @persist_strategy didn't set as instance OrderStrategy::PersistBase
  end # #coupon_by_strategy

  describe '#coupon_id_by_strategy' do
    before { order.coupon = create :coupon }
    it "tries call #id on coupon" do
      expect(order.coupon).to receive(:try).with(:id)
      order.coupon_id_by_strategy
    end
  end # #coupon_id_by_strategy

  describe '#coupon_by_strategy=' do
    let(:persist_strategy){ double("instance OrderStrategy::PersistBase") }
    let(:object) { 'some object' }
    before(:each) { order.instance_variable_set(:@persist_strategy, persist_strategy) }
    it "calls #set_coupon for @persist_strategy" do
      expect(persist_strategy).to receive(:set_coupon).with(order, object)
      order.coupon_by_strategy = object
    end
  end # #coupon_by_strategy=

end
