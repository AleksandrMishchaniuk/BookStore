require 'rails_helper'

RSpec.describe Shop::ReviewsController, type: :controller do
  let(:book) { create(:book) }
  let(:book_id) { book.id }

  shared_examples 'when user is not loged in' do
    context 'when user is not loged in' do
      it 'redirects to sign in page' do
        query
        expect(response).to redirect_to new_user_session_path
      end
    end # 'when user is not loged in'
  end
  shared_examples 'when book id is not valid' do
    context 'when book id is not valid' do
      let(:book_id) { 0 }
      let(:back) { shop_book_path(book_id) }
      before { controller.request.env['HTTP_REFERER'] = back }
      it 'redirects to :back' do
        query
        expect(response).to redirect_to back
      end
    end # 'when book id is not valid'
  end

  describe 'GET #new' do
    let(:query){ get :new, book_id: book_id }

    context 'when user is loged in' do
      let(:user){ create(:user) }
      before { sign_in user }
      it 'renders :new template' do
        query
        expect(response).to render_template :new
      end
      it 'sets variable @review as new review with field :book_id' do
        query
        expect(assigns(:review)).to be_kind_of(Review)
        expect(assigns(:review)).to_not be_persisted
        expect(assigns(:review).book_id).to eq(book.id)
      end
      include_examples 'when book id is not valid'
    end # 'when user is loged in'
    include_examples 'when user is not loged in'
  end # 'GET #new'

  describe 'POST #create' do
    let(:resource_params) { attributes_for(:review) }
    let(:query) { post :create, review: resource_params, book_id: book_id }

    context 'when user is loged in' do
      let(:user){ create(:user) }
      before { sign_in user }
      context 'when params are valid' do
        it 'redirects to book page' do
          query
          expect(response).to redirect_to shop_book_path(book_id)
        end
        it 'creates a new review with current book id' do
          query
          expect(assigns(:review)).to be_kind_of(Review)
          expect(assigns(:review)).to be_persisted
          expect(assigns(:review).book_id).to eq(book_id)
        end
      end
      context 'when params are not valid' do
        before { resource_params.each_key { |k| resource_params[k] = '' } }
        it 'renders :new template' do
          query
          expect(response).to render_template :new
        end
        it 'sets errors for review' do
          query
          expect(assigns(:review).errors).to_not be_empty
        end
      end
      include_examples 'when book id is not valid'
    end # 'when user is loged in'
    include_examples 'when user is not loged in'
  end # 'POST #create'

end
