require 'rails_helper'

feature 'i18n' do
  background{ allow(Book).to receive(:bestsellers).and_return([]) }

  scenario 'change language to russian' do
    visit root_path
    expect(find('.navbar')).to have_link('Home')
    click_on('RU')
    expect(find('.navbar')).to have_link('Главная')
  end

  scenario 'change language to english' do
    visit root_locale_path(locale: 'ru')
    expect(find('.navbar')).to have_link('Главная')
    click_on('EN')
    expect(find('.navbar')).to have_link('Home')
  end

end
