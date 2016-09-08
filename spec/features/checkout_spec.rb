require 'rails_helper'

feature 'Checkout' do
  given(:order) { create :order }
  background(:each) { page.set_rack_session(order_in_progress_id: order.id) }

  context 'visit addresses page' do
    given(:address) { build :address }

    scenario do
      visit edit_checkout_addresses_path
      expect(find('#checkout_panel .current')).to have_content('ADDRESSES')
      expect(find('#checkout_panel')).to_not have_css('a')
      expect(page).to have_css('.order_summary')
    end

    scenario 'user types write address data' do
      visit edit_checkout_addresses_path
      within("#edit_order_#{order.id}") do
        fill_in('order_billing_address_first_name', with: address.first_name)
        fill_in('order_billing_address_last_name', with: address.last_name)
        fill_in('order_billing_address_address_line', with: address.address_line)
        fill_in('order_billing_address_city', with: address.city)
        fill_in('order_billing_address_country', with: address.country)
        fill_in('order_billing_address_zip', with: address.zip)
        fill_in('order_billing_address_phone', with: address.phone)
        find('#once_address').set(true)
        find('[name="commit"]').click
      end
      expect(page).to have_current_path(edit_checkout_delivery_path(locale: 'en'))
    end

    scenario 'user types wrong address data' do
      visit edit_checkout_addresses_path
      within("#edit_order_#{order.id}") do
        fill_in('order_billing_address_first_name', with: address.first_name)
        fill_in('order_billing_address_last_name', with: '')
        fill_in('order_billing_address_address_line', with: address.address_line)
        fill_in('order_billing_address_city', with: address.city)
        fill_in('order_billing_address_country', with: address.country)
        fill_in('order_billing_address_zip', with: address.zip)
        fill_in('order_billing_address_phone', with: address.phone)
        find('#once_address').set(true)
        find('[name="commit"]').click
      end
      expect(page).to have_current_path(checkout_addresses_path(locale: 'en'))
      expect(page).to have_css('.text-danger')
    end

    context 'when order already has delivery and payment' do
      background(:each) do
        order.delivery = create :delivery
        order.credit_card = create :credit_card
        order.save
      end
      scenario do
        visit edit_checkout_addresses_path
        expect(find('#checkout_panel .current')).to have_content('ADDRESSES')
        expect(find('#checkout_panel')).to have_link('DELIVERY')
        expect(find('#checkout_panel')).to have_link('PAYMENT')
        expect(find('#checkout_panel')).to have_link('CONFIRM')
      end
    end

    context 'when order already has delivery' do
      background(:each) do
        order.delivery = create :delivery
        order.save
      end
      scenario do
        visit edit_checkout_addresses_path
        expect(find('#checkout_panel .current')).to have_content('ADDRESSES')
        expect(find('#checkout_panel')).to have_link('DELIVERY')
        expect(find('#checkout_panel')).to_not have_link('PAYMENT')
        expect(find('#checkout_panel')).to_not have_link('CONFIRM')
      end
    end
  end # visit addresses page


  context 'visit delivery page' do
    background { 3.times.each { create :delivery } }

    context 'when order does not have billing address' do
      scenario 'redirects to addresses page' do
        visit edit_checkout_delivery_path
        expect(page).to have_current_path(edit_checkout_addresses_path(locale: 'en'))
      end
    end # when order does not have billing address

    context 'when order have billing address' do
      background do
        order.billing_address = order.shipping_address = create :address
        order.save
      end
      scenario do
        visit edit_checkout_delivery_path
        expect(find('#checkout_panel .current')).to have_content('DELIVERY')
        expect(find('#checkout_panel')).to have_link('ADDRESSES')
        expect(find('#checkout_panel')).to_not have_link('PAYMENT')
        expect(find('#checkout_panel')).to_not have_link('CONFIRM')
        expect(page).to have_css('.order_summary')
      end
      scenario 'one of deliveries is checked by default' do
        visit edit_checkout_delivery_path
        within("#edit_order_#{order.id}") do
          find('[name="commit"]').click
        end
        expect(page).to have_current_path(edit_checkout_payment_path(locale: 'en'))
      end
    end # when order have billing address
  end # visit delivery page


  context 'visit payment page' do
    given(:credit_card) { build :credit_card }
    background do
      order.billing_address = order.shipping_address = create :address
      order.save
    end

    context 'when order does not have delivery' do
      scenario 'redirects to delivery page' do
        visit edit_checkout_payment_path
        expect(page).to have_current_path(edit_checkout_delivery_path(locale: 'en'))
      end
    end # when order does not have delivery

    context 'when order have delivery' do
      background do
        order.delivery = create :delivery
        order.save
      end
      scenario do
        visit edit_checkout_payment_path
        expect(find('#checkout_panel .current')).to have_content('PAYMENT')
        expect(find('#checkout_panel')).to have_link('ADDRESSES')
        expect(find('#checkout_panel')).to have_link('DELIVERY')
        expect(find('#checkout_panel')).to_not have_link('CONFIRM')
        expect(page).to have_css('.order_summary')
      end

      scenario 'user types write credit card data' do
        visit edit_checkout_payment_path
        within("#edit_order_#{order.id}") do
          fill_in('credit_card_number', with: credit_card.number)
          year = find('#credit_card_expiration_date_1i option[1]').text
          month = find('#credit_card_expiration_date_2i option[1]').text
          select(year, from: 'credit_card_expiration_date_1i')
          select(month, from: 'credit_card_expiration_date_2i')
          fill_in('credit_card_code', with: credit_card.code)
          find('[name="commit"]').click
        end
        expect(page).to have_current_path(checkout_confirm_path(locale: 'en'))
      end

      scenario 'user types wrong credit card data' do
        visit edit_checkout_payment_path
        within("#edit_order_#{order.id}") do
          fill_in('credit_card_number', with: '1111111111111111')
          year = find('#credit_card_expiration_date_1i option[1]').text
          month = find('#credit_card_expiration_date_2i option[1]').text
          select(year, from: 'credit_card_expiration_date_1i')
          select(month, from: 'credit_card_expiration_date_2i')
          fill_in('credit_card_code', with: credit_card.code)
          find('[name="commit"]').click
        end
        expect(page).to have_current_path(checkout_payment_path(locale: 'en'))
        expect(page).to have_css('.text-danger')
      end
    end # when order have delivery
  end # visit payment page

  context 'visit confirm page' do
    background do
      order.billing_address = order.shipping_address = create :address
      order.delivery = create :delivery
      order.save
    end

    context 'when order does not have credit card' do
      scenario 'redirects to payment page' do
        visit checkout_confirm_path
        expect(page).to have_current_path(edit_checkout_payment_path(locale: 'en'))
      end
    end # when order does not have credit card

    context 'when order has credit card' do
      background do
        order.credit_card = create :credit_card
        order.save
      end
      scenario do
        visit checkout_confirm_path
        expect(find('#checkout_panel .current')).to have_content('CONFIRM')
        expect(find('#checkout_panel')).to have_link('ADDRESSES')
        expect(find('#checkout_panel')).to have_link('DELIVERY')
        expect(find('#checkout_panel')).to have_link('PAYMENT')
      end

      scenario 'page show information about order' do
        visit checkout_confirm_path
        expect(page).to have_content(order.billing_address.last_name)
        expect(page).to have_content(order.shipping_address.city)
        expect(page).to have_content(order.delivery.delivery_type)
        expect(page).to have_content(order.credit_card.number[-4,4])
        expect(page).to have_css('.cart_items')
        order.books.each do |book|
          expect(page).to have_content(book.title)
        end
      end

      scenario 'opens complete page after confirm' do
        visit checkout_confirm_path
        click_on 'Place order'
        expect(page).to have_current_path(checkout_to_queue_path(locale: 'en'))
      end
    end # when order has credit card
  end # visit confirm page

  context 'visit complete page' do
    background do
      order.billing_address = order.shipping_address = create :address
      order.delivery = create :delivery
      order.credit_card = create :credit_card
      order.save
    end

    scenario 'page show information about order' do
      visit checkout_to_queue_path
      expect(page).to have_content(order.number)
      expect(page).to have_content(order.billing_address.last_name)
      expect(page).to have_content(order.shipping_address.city)
      expect(page).to have_content(order.delivery.delivery_type)
      expect(page).to have_content(order.credit_card.number[-4,4])
      expect(page).to have_css('.cart_items')
      order.books.each do |book|
        expect(page).to have_content(book.title)
      end
    end
  end # visit complete page

end
