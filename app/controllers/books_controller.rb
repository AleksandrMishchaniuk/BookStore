class BooksController < ApplicationController
  before_action :set_book, only: :show

  # GET /books
  # GET /books.json
  def index
    @books = Book.all
  end

  # GET /books/1
  # GET /books/1.json
  def show
  end

  private
    def set_book
      @book = Book.find(params[:id])
    end
end
