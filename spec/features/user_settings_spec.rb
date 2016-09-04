require 'rails_helper'

feature 'User settings' do
  given(:current_password) { FFaker::Internet.password }
  given(:user) { create :user, password: current_password }
  given(:address_types) { ['billing', 'shipping'] }
  given(:address_fields) { ['first_name', 'last_name', 'address_line', 'city', 'country', 'zip', 'phone'] }
  background do
    login_as user
  end

  context 'when user does not have addresses' do
    scenario 'page has empty address forms' do
      visit edit_user_settings_path
      address_types.each do |type|
        address_fields.each do |field|
          id = "user_#{type}_address_#{field}"
          expect(find("##{id}").value).to be_nil
        end
      end
    end
  end # when user does not have addresses

  context 'when user has addresses' do
    background do
      user.billing_address = create :address
      user.shipping_address = create :address
    end
    scenario 'page has prefilled address forms' do
      visit edit_user_settings_path
      address_types.each do |type|
        address_fields.each do |field|
          id = "user_#{type}_address_#{field}"
          expect(find("##{id}").value).to eq(user.send("#{type}_address").send(field))
        end
      end
    end
  end # when user has addresses

  scenario 'page has prefilled email field' do
    visit edit_user_settings_path
    expect(find('#user_email').value).to eq(user.email)
  end

  context 'when user changed or filled addresses' do
    given(:new_billing_address){ create :address }
    given(:new_shipping_address){ create :address }
    scenario do
      visit edit_user_settings_path
      address_types.each do |type|
        within("#edit_user_#{type}_address") do
          address_fields.each do |field|
            id = "user_#{type}_address_#{field}"
            fill_in(id, with: send("new_#{type}_address").send(field))
          end
          find('[name="commit"]').click
        end
        address_fields.each do |field|
          id = "user_#{type}_address_#{field}"
          expect(find("##{id}").value).to eq(send("new_#{type}_address").send(field))
        end
      end
    end
  end # when user changed or filled addresses

  context 'when user changed email' do
    given(:new_email) { FFaker::Internet.email }
    scenario do
      visit edit_user_settings_path
      within('#edit_user_email') do
        fill_in('user_email', with: new_email)
        find('[name="commit"]').click
      end
      expect(find('#user_email').value).to eq(new_email)
    end
    context 'when user with new email already exists' do
      background { create(:user, email: new_email) }
      scenario do
        visit edit_user_settings_path
        within('#edit_user_email') do
          fill_in('user_email', with: new_email)
          find('[name="commit"]').click
        end
        expect(find('#user_email').value).to_not eq(new_email)
        expect(page).to have_css('.text-danger')
      end
    end # when user with new email already exists
  end # when user changed email

  context 'when user removes his account' do
    context 'when confirm checkbox did not set' do
      scenario 'does not reremove account' do
        visit edit_user_settings_path
        within('#remove_user_account') do
          find('[name="commit"]').click
        end
        expect(page).to have_current_path(edit_user_settings_path(locale: 'en'))
        expect(page).to have_css('.text-danger')
      end
    end # when confirm checkbox does not set

    context 'when confirm checkbox sed' do
      scenario 'does not reremove account' do
        visit edit_user_settings_path
        within('#remove_user_account') do
          find('#confirm').set(true)
          find('[name="commit"]').click
        end
        expect(page).to have_current_path(new_user_session_path(locale: 'en'))
        expect(page).to have_css('.text-success')
      end
    end
  end # when user removes his account

  context 'when user change password' do
    given(:new_password) { FFaker::Internet.password }
    context 'when user types true current password' do
      scenario do
        visit edit_user_settings_path
        within('#change_user_password') do
          fill_in('user_current_password', with: current_password)
          fill_in('user_password', with: new_password)
          fill_in('user_password_confirmation', with: new_password)
          find('[name="commit"]').click
        end
        expect(page).to have_css('.text-success')
      end
    end # when user types true current password

    context 'when user types wrong current password' do
      given(:wrong_password) { FFaker::Internet.password }
      scenario do
        visit edit_user_settings_path
        within('#change_user_password') do
          fill_in('user_current_password', with: wrong_password)
          fill_in('user_password', with: new_password)
          fill_in('user_password_confirmation', with: new_password)
          find('[name="commit"]').click
        end
        expect(page).to have_css('.text-danger')
      end
    end # when user types wrong current password
  end # when user change password
end
