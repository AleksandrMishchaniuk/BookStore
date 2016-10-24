module Shop
  # :nodoc:
  class BooksController < ::ApplicationController
    def index
      @books = Book.page(params[:page]).per(6)
    end

    def show
      @book = Book.find(params[:id])
      @reviews = @book.approved_reviews
      @in_cart = @order.cart_item(@book.id)
      @cart = Cart.new(book_id: @book.id, book_count: 1)
    rescue
      redirect_to shop_books_path
    end
  end
end
