require 'rails_helper'

RSpec.describe CartController, type: :controller do
  include OdrderInProgressHelpers
  include CartControllerSharedExamples
  before(:each) { request.env["HTTP_REFERER"] = cart_path }
  let(:resource_params){{ book_id: nil, book_count: nil }}

  shared_context 'when order is not persisted and cart items exist' do
    before(:each) do
      order_from_session_by_cart_items
      get :show
    end
  end

  shared_context 'when order is persisted' do
    before(:each) do
      order_by_id_from_session
      get :show
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show
      expect(response).to have_http_status(:success)
    end
    it "passes to view @order variable" do
      get :show
      expect(assigns(:order)).to be_kind_of(Order)
    end
    context 'when order is not persisted and cart items exist' do
      include_context 'when order is not persisted and cart items exist'
      it { expect(assigns(:order).cart_items).to_not be_empty }
      it { expect(assigns(:order)).to_not be_persisted }
    end
    context 'when order is persisted' do
      include_context 'when order is persisted'
      it { expect(assigns(:order).cart_items).to_not be_empty }
      it { expect(assigns(:order)).to be_persisted }
    end
  end

  describe 'POST #add_item' do
    let(:query) { post :add_item, cart: resource_params }
    let(:add_item_action?) {true}

    context 'when order is not persisted and cart items exist' do
      include_context 'when order is not persisted and cart items exist'
      include_examples 'add when new cart item'
      include_examples 'update when cart item already exists'
      include_examples 'redirect'
    end

    context 'when order is not persisted and cart items do not exist' do
      before(:each) { get :show }
      it { expect(assigns(:order).cart_items).to be_empty }
      include_examples 'add when new cart item'
      include_examples 'redirect'
    end

    context 'when order is persisted' do
      include_context 'when order is persisted'
      include_examples 'add when new cart item'
      include_examples 'update when cart item already exists'
      include_examples 'redirect'
    end
  end

  describe 'POST #update_item' do
    let(:query) { post :update_item, cart: resource_params, format: :json }
    let(:resource_params) {{ book_id: assigns(:order).cart_items[0].book_id, book_count: 1 }}
    let(:add_item_action?) {false}

    context 'when order is not persisted and cart items exist' do
      include_context 'when order is not persisted and cart items exist'
      include_examples 'update when cart item already exists'

      it "renders :update_item template" do
        query
        expect(response).to render_template :update_item
      end
    end

    context 'when order is persisted' do
      include_context 'when order is persisted'
      include_examples 'update when cart item already exists'

      it "renders :update_item template" do
        query
        expect(response).to render_template :update_item
      end
    end
  end

  describe 'DELETE #remove_item' do
    let(:query) { delete :remove_item, id: item.book.id }

    context 'when order is not persisted and cart items exist' do
      include_context 'when order is not persisted and cart items exist'
      include_examples 'removes item from cart'
    end

    context 'when order is persisted' do
      include_context 'when order is persisted'
      include_examples 'removes item from cart'
      context 'when cart is empty after removing item' do
        it 'destroies order' do
          assigns(:order).cart_items.each { |i| i.delete unless i.id == item.id }
          query
          expect(assigns(:order)).to_not be_persisted
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:query) { delete :destroy }

    context 'when order is not persisted and cart items exist' do
      include_context 'when order is not persisted and cart items exist'
      it 'removes all items from cart' do
        query
        expect(assigns(:order).cart_items).to be_empty
      end
      include_examples 'redirect'
    end

    context 'when order is persisted' do
      include_context 'when order is persisted'
      it 'removes all items from cart and destroies order' do
        query
        expect(assigns(:order).cart_items).to be_empty
        expect(assigns(:order)).to_not be_persisted
      end
      include_examples 'redirect'
    end
  end

  describe 'POST #update_coupon' do
    let(:query) { post :update_coupon, coupon: code }
    let(:coupon) { create(:coupon).reload }

    shared_examples 'base coupon expectations' do
      before do
        allow_any_instance_of(Order).to receive(:session).and_return(controller.session)
        controller.instance_variable_set(:@order, order)
      end
      let(:code) { coupon.code }
      it 'redirects to :show page' do
        query
        expect(response).to redirect_to cart_path
      end
      context 'when coupon code exists' do
        it 'sets value for @order.coupon' do
          query
          expect(order.coupon).to eq(coupon)
        end
        context 'when coupon already used' do
          before(:each) do
            order.coupon = nil
            coupon.update_attributes(used: true)
          end
          it 'sets @order.coupon to nil' do
            query
            expect(order.coupon).to be_nil
          end
          it 'sends alert flash' do
            query
            expect(flash[:alert]).to_not be_nil
          end
        end # 'when coupon already used'
      end # 'when coupon code exists'

      context 'when coupon code does not exist' do
        let(:code) { 0000 }
        it 'sends alert flash' do
          query
          expect(flash[:alert]).to_not be_nil
        end
      end # 'when coupon code does not exist'
    end # shared_examples 'base coupon expectations'

    context 'when order is persisted' do
      let(:order) { create(:order).reload }
      include_examples 'base coupon expectations'
    end # 'when order is persisted'
    context 'when order is not persisted' do
      let(:order) { build(:order) }
      include_examples 'base coupon expectations'
    end # 'when order is not persisted'

  end # 'POST #update_coupon'
end
