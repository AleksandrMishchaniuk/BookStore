require 'rails_helper'

RSpec.describe Book, type: :model do

  describe '.bestsellers' do
    let(:books) { 10.times.map { create :book } }
    let(:queue) do
      [
        {
          count: 5,
          book: books[3]
        },
        {
          count: 4,
          book: books[8]
        },
        {
          count: 3,
          book: books[1]
        },
        {
          count: 2,
          book: books[2]
        },
        {
          count: 2,
          book: books[6]
        },
        {
          count: 1,
          book: books[5]
        }
      ].shuffle!
    end
    let(:count) { 3 }
    let(:bestsellers) { [ books[3], books[8], books[1] ] }

    context 'when one target book in order' do
      before(:each) do
        queue.each do |item|
          item[:count].times.each do
            order = create :order_in_queue
            order.carts.each { |cart| cart.update({book_count: 1}) }
            create(:cart, book: item[:book], order: order, book_count: 1)
          end
        end
      end

      it do
        expect(Book.bestsellers(count)).to eq(bestsellers)
      end
    end # when one target book in order

    context 'when several target books in order' do
      before(:each) do
        queue.each do |item|
          order = create :order_in_queue
          order.carts.each { |cart| cart.update({book_count: 1}) }
          create(:cart, book: item[:book], order: order, book_count: item[:count])
        end
      end

      it do
        expect(Book.bestsellers(count)).to eq(bestsellers)
      end
    end # when several target books in order
  end # .bestsellers

  describe '#approved_reviews' do
    it "calls method .approved on reviews collection" do
      book = create :book
      expect(book.reviews).to receive(:approved)
      book.send(:approved_reviews)
    end
  end

end
