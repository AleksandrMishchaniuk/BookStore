require 'rails_helper'

feature 'Home page' do
  background :each do
    3.times.each { create :order }
  end
  scenario 'visit home page' do
      visit '/'
      expect(page).to have_content 'Welcome'
      expect(page).to have_content 'Bestsellers'
      expect(page).to have_css '.slide'
  end
end
