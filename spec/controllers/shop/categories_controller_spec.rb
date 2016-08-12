require 'rails_helper'

RSpec.describe Shop::CategoriesController, type: :controller do

  describe 'GET #show' do
    let(:query) { get :show, id: resource_id }
    context 'when category id is valid' do
      let(:resource) { create(:category_with_books) }
      let(:resource_id) { resource.id }
      before { 5.times { create(:book) } }
      it 'renders :show page' do
        query
        expect(response).to render_template :show
      end
      it 'defines @books variable' do
        query
        assigns(:books).each do |book|
          expect(resource.books).to include(book)
        end
      end
    end # 'when category id is valid'
    context 'when category id is not valid' do
      let(:resource_id) { 0 }
      it 'redirects to shop page' do
        query
        expect(response).to redirect_to shop_books_path
      end
    end # 'when category id not is valid'
  end

end
