require 'rails_helper'

RSpec.describe Category, type: :model do

  describe '.items_for_navigation' do
    let(:names) { [ 'category 1', 'category 2', 'category 3' ] }
    let(:categories) { names.map { |name| create(:category, name: name) } }
    let(:expectation) do
      <<-RES
category.item "category 1", "category 1", '/'+I18n.locale.to_s+'/shop/categories/#{categories[0].id}', html: {class: 'some_class'}
category.item "category 2", "category 2", '/'+I18n.locale.to_s+'/shop/categories/#{categories[1].id}', html: {class: 'some_class'}
category.item "category 3", "category 3", '/'+I18n.locale.to_s+'/shop/categories/#{categories[2].id}', html: {class: 'some_class'}
      RES
    end
    before { expectation }
    it do
      expect(described_class.items_for_navigation('some_class')+"\n").to be_eql(expectation)
    end
  end

end
