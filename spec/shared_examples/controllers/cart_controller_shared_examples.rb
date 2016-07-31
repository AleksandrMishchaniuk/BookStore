module CartControllerSharedExamples
  shared_examples 'redirect' do
    it 'redirects' do
      query
      expect(response).to have_http_status(:redirect)
    end
  end

  shared_examples "add when new cart item" do
    context 'when new cart item' do
      let(:book) { create(:book) }
      let(:resource_params) {{ book_id: book.id, book_count: rand(1..5) }}
      it "adds new item to cart" do
        expect { query }.to change{ assigns(:order).cart_items.size }.by(1)
        is_include = assigns(:order).cart_items.inject(false){ |res, item| res || item.book_id == book.id }
        expect(is_include).to be true
      end
    end
  end

  shared_examples "update when cart item already exists" do
    context 'when cart item already exists' do
      let(:item) { assigns(:order).cart_items.sample }
      let(:resource_params) {{ book_id: item.book.id, book_count: rand(1..5) }}
      let(:matcher_count) do
        (add_item_action?)? resource_params[:book_count]:
                            resource_params[:book_count] - item.book_count
      end
      it " changes cart item book's count by book_count" do
        book_count = -> do
          item.reload if item.persisted?
          item.book_count
        end
        expect { query }.to change(&book_count).by(matcher_count)
      end
      it "should not change cart items count" do
        expect { query }.to_not change{ assigns(:order).cart_items.size }
      end
    end
  end

  shared_examples 'removes item from cart' do
    let(:item) { assigns(:order).cart_items.sample }
    it 'removes item from cart' do
      expect{ query }.to change{ assigns(:order).cart_items.size }.by(-1)
      expect(assigns(:order).cart_items).to_not include(item)
    end
    include_examples 'redirect'
  end
end
