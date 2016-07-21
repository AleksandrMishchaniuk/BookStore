class Shop::BooksController < ApplicationController
  def index
    @books = Book.page(params[:page]).per(6)
  end

  def show
    @book = Book.find(params[:id])
    @reviews = @book.approved_reviews
    @cart = Cart.in_process || Cart.new
  end
end
