require 'rails_helper'

RSpec.describe Shop::BooksController, type: :controller do

  describe 'GET #index' do
    let(:query) { get :index }
    before { 5.times { create(:book) } }
    it 'renders :index template' do
      query
      expect(response).to render_template :index
    end
    it 'defines @books variable' do
      query
      assigns(:books).each do |book|
        expect(book).to be_kind_of(Book)
      end
    end
  end

  describe 'GET #show' do
    let(:query) { get :show, id: resource_id }

    context 'when book id is valid' do
      let(:resource) { create(:book).reload }
      let(:resource_id) { resource.id }
      it 'renders :show template' do
        query
        expect(response).to render_template(:show)
      end
      it 'sets variable @book' do
        query
        expect(assigns(:book)).to eq(resource)
      end
      it 'sets variable @cart' do
        query
        expect(assigns(:cart)).to be_kind_of(Cart)
        expect(assigns(:cart).book_id).to eq(resource_id)
      end
      context 'when book is already in cart' do
        let(:item_in_cart) { Cart.new(book_id: resource_id, book_count: 3) }
        before do
          controller.instance_variable_set(:@order, build(:order))
          assigns(:order).carts << item_in_cart
        end
        it do
          query
          expect(assigns(:in_cart)).to eq(item_in_cart)
        end
      end
      context 'when book is not in cart yet' do
        it do
          query
          expect(assigns(:in_cart)).to be_nil
        end
      end
      context 'when book has approved reviews' do
        let(:user) { create(:user) }
        let(:reviews) { (1..3).map { create(:review, book_id: resource_id, user_id: user.id, approved: true) } }
        it 'sets variable @reviews as array of reviews' do
          query
          expect(assigns(:reviews)).to eq(reviews)
        end
      end
      context 'when book does not have approved reviews' do
        let(:user) { create(:user) }
        let(:reviews) { (1..3).map { create(:review, book_id: resource_id, user_id: user.id) } }
        it 'sets variable @reviews as nill' do
          query
          expect(assigns(:reviews)).to be_empty
        end
      end
    end # 'when book id is valid'

    context 'when book id is not valid' do
      let(:resource_id) { 0 }
      it 'redirects to shop books page' do
        query
        expect(response).to redirect_to shop_books_path
      end
    end # 'when book id is not valid'

  end

end
