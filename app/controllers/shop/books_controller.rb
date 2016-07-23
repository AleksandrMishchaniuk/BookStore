class Shop::BooksController < ApplicationController
  before_action :define_order_in_progress, only: [:show]

  def index
    @books = Book.page(params[:page]).per(6)
  end

  def show
    @book = Book.find(params[:id])
    @reviews = @book.approved_reviews
    @in_cart = @order.cart_items.find { |item| item.book_id == @book.id.to_i}
    @cart = Cart.new(book_id: @book.id, book_count: 1)
  end
end
