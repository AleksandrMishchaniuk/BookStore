class Shop::BooksController < ApplicationController
  def index
    @books = Book.page(params[:page]).per(6)
  end
end
