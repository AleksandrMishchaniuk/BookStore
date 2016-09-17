require 'rails_helper'

feature 'Cart' do

  shared_examples 'cart expectations' do
    scenario 'present count of items in the cart' do
      visit root_path
      expect(find('.li_cart .badge')).to have_content(order.cart_items.size)
    end

    context 'when cart does not have target book' do
      given(:book) { create :book }
      given(:count) { 2 }
      scenario 'add book to cart' do
        items_count = order.cart_items.size
        visit shop_book_path(id: book.id)
        expect(page).to_not have_content('already in cart')
        expect(find('.li_cart .badge')).to have_content(items_count)
        within('#new_cart') do
          fill_in('cart_book_count', with: count)
          click_on('Add to Cart')
        end
        expect(page).to have_content("already in cart: #{count}")
        expect(find('.li_cart .badge')).to have_content(items_count + 1)
      end # add book to cart
    end # when cart does not have target book

    context 'when cart has target book' do
      given(:book) { create :book }
      given(:new_count) { 2 }
      given(:old_count) { 3 }
      background do
        if order.persisted?
          create(:cart, book: book, book_count: old_count, order: order)
          order.reload
        else
          order.carts << build(:cart, book: book, book_count: old_count)
          page.set_rack_session(get_not_persisted_order_session(order))
        end
      end
      scenario 'add book to cart' do
        items_count = order.cart_items.size
        visit shop_book_path(id: book.id)
        expect(page).to have_content("already in cart: #{old_count}")
        expect(find('.li_cart .badge')).to have_content(items_count)
        within('#new_cart') do
          fill_in('cart_book_count', with: new_count)
          click_on('Add to Cart')
        end
        expect(page).to have_content("already in cart: #{old_count + new_count}")
        expect(find('.li_cart .badge')).to have_content(items_count)
      end # add book to cart
    end # when cart has target book

    scenario 'remove book from cart' do
      items_count = order.cart_items.size
      book = order.cart_items[0].book
      visit cart_path
      expect(page).to have_content(book.title)
      expect(find('.li_cart .badge')).to have_content(items_count)
      within("[data-book_id='#{book.id}']") do
        find('[title="remove"]').click
      end
      expect(page).to_not have_content(book.title)
      expect(find('.li_cart .badge')).to have_content(items_count - 1)
    end

    scenario 'click button "Empty cart"' do
      visit cart_path
      click_on('Empty cart')
      expect(page).to have_content('Cart is empty')
    end

    scenario 'visit to cart page when cart is empty' do
      session = {}
      session[OrderFactory::STORAGE_KEY] = nil
      page.set_rack_session(session)
      order.destroy
      visit cart_path
      expect(page).to have_content('Cart is empty')
    end

    scenario 'type write coupon code' do
      coupon = create :coupon
      visit cart_path
      expect(page).to_not have_content('DISCOUNT')
      within('.coupon_form') do
        fill_in('coupon', with: coupon.code)
        find('[name="commit"]').click
      end
      expect(page).to have_content('DISCOUNT')
    end

    context 'when order has coupon' do
      let(:coupon) { create :coupon }
      background do
        if order.persisted?
          order.coupon = coupon
        else
          page.set_rack_session(get_not_persisted_order_session_with_coupon(order, coupon))
        end
      end
      scenario 'type wrong coupon code' do
        visit cart_path
        expect(page).to have_content('DISCOUNT')
        within('.coupon_form') do
          fill_in('coupon', with: coupon.code.to_s + '0')
          find('[name="commit"]').click
        end
        expect(page).to_not have_content('DISCOUNT')
        expect(page).to have_css('.alert')
      end
    end # when order has coupon

    scenario 'click on button "Checkout"' do
      visit cart_path
      click_on('Checkout')
      expect(page).to have_current_path(edit_checkout_addresses_path(locale: 'en'))
    end
  end # cart expectations

  context 'when order is persisted' do
    given(:order) { create :order }
    background(:each) do
      page.set_rack_session(get_persisted_order_session(order))
    end
    include_examples 'cart expectations'
  end # when order is persisted

  context 'when order is not persisted' do
    given(:order) { build :order }
    background(:each) do
      page.set_rack_session(get_not_persisted_order_session(order))
    end
    include_examples 'cart expectations'
  end # when order is not persisted

  def get_persisted_order_session(order)
    storage = {}
    storage[OrderFactory::PERSISTED_KEY] = order.id
    session = {}
    session[OrderFactory::STORAGE_KEY] = storage
    session
  end

  def get_not_persisted_order_session(order)
    storage = {}
    storage[OrderFactory::NOT_PERSISTED_KEY] = order.cart_items_to_array
    session = {}
    session[OrderFactory::STORAGE_KEY] = storage
    session
  end

  def get_not_persisted_order_session_with_coupon(order, coupon)
    storage = {}
    storage[OrderFactory::COUPON_KEY] = coupon.id
    session = get_not_persisted_order_session(order)
    session[OrderFactory::COUPON_STORAGE_KEY] = storage
    session
  end
end
