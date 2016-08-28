require 'rails_helper'

feature 'Cart' do
  given(:order) { create :order }
  background(:each) { page.set_rack_session(order_in_progress_id: order.id) }
  scenario 'present count of items in the cart' do
    visit root_path
    expect(find('.li_cart .badge')).to have_content(order.cart_items.count)
  end

  context 'when cart does not have target book' do
    given(:book) { create :book }
    given(:count) { 2 }
    scenario 'add book to cart' do
      items_count = order.cart_items.count
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
      create(:cart, book: book, book_count: old_count, order: order)
    end
    scenario 'add book to cart' do
      items_count = order.cart_items.count
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
    items_count = order.cart_items.count
    book = order.books[0]
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
    page.set_rack_session(order_in_progress_id: nil)
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

  scenario 'type wrong coupon code' do
    coupon = create :coupon
    order.coupon = coupon
    visit cart_path
    expect(page).to have_content('DISCOUNT')
    within('.coupon_form') do
      fill_in('coupon', with: coupon.code.to_s + '0')
      find('[name="commit"]').click
    end
    expect(page).to_not have_content('DISCOUNT')
    expect(page).to have_css('.alert')
  end

  scenario 'click on button "Checkout"' do
    visit cart_path
    click_on('Checkout')
    expect(page).to have_current_path(edit_checkout_addresses_path(locale: 'en'))
  end
end
