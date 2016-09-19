require "rails_helper"

RSpec.describe Cart, type: :model do

  describe '#total_price' do
    it "returns price of catr item" do
      book = create(:book, price: 6)
      cart = build(:cart, book: book, book_count: 4)
      expect(cart.total_price).to eq(24)
    end
  end

end
