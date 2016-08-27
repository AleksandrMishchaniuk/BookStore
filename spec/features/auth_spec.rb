require 'rails_helper'

feature 'Auth' do
  given(:user){ create :user }
  background{ allow(Book).to receive(:bestsellers).and_return([]) }

  scenario "Sign in" do
    visit new_user_session_path(locale: 'en')
    within('#new_user') do
      fill_in('user_email', with: user.email)
      fill_in('user_password', with: user.password)
      click_on('Sign in')
    end
    expect(find('.navbar')).to have_link('Sign Out')
    expect(find('.navbar')).to have_content(user.email)
  end # Sign in

  scenario "Sign out" do
    login_as user
    visit root_path
    click_on('Sign Out')
    expect(find('.navbar')).to have_link('Sign In')
    expect(find('.navbar')).to_not have_content(user.email)
  end # Sign out

  context do
    given(:user){ build :user }
    scenario "Sign up" do
      visit new_user_registration_path(locale: 'en')
      within('#new_user') do
        fill_in('user_email', with: user.email)
        fill_in('user_password', with: user.password)
        fill_in('user_password_confirmation', with: user.password)
        click_on('Sign up')
      end
      expect(find('.navbar')).to have_link('Sign Out')
      expect(find('.navbar')).to have_content(user.email)
    end # Sign up
  end

end
