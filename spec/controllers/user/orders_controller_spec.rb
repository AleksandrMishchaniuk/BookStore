require 'rails_helper'

RSpec.describe User::OrdersController, type: :controller do
  let(:user) { create(:user) }
  before(:each) { sign_in user }

  describe 'GET #index' do
    before(:each) { get :index }

    context 'when user is not loged in' do
      it 'redirects to login page' do
        sign_out user
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end
    context 'when user loged in' do
      it 'renders :index template' do
        expect(response).to render_template :index
      end
      it 'finds orders in queue, in delivery and delivered from current user' do
        allow(controller).to receive(:current_user).and_return(user)
        expect(Order).to receive(:in_queue)
        expect(Order).to receive(:in_delivery)
        expect(Order).to receive(:delivered)
        get :index
      end
    end
  end

  describe 'GET #show' do
    let(:order) { create(:order) }
    let(:query_correct) { get :show, id: order.id }
    let(:query_uncorrect) { get :show, id: 0 }
    before { user.orders << order }

    context 'when user is not loged in' do
      it 'redirects to login page' do
        sign_out user
        query_correct
        expect(response).to redirect_to new_user_session_path
      end
    end
    context 'when user loged in' do
      it 'finds order by id' do
        allow(controller).to receive(:current_user).and_return(user)
        expect(Order).to receive(:find).with(order.id)
        query_correct
      end
      context 'when order id is correct' do
        it 'renders :show template' do
          query_correct
          expect(response).to render_template :show
        end
      end
      context 'when order id is uncorrect' do
        it 'renders :show template' do
          query_uncorrect
          expect(response).to redirect_to user_orders_path
        end
      end
    end
  end
end
