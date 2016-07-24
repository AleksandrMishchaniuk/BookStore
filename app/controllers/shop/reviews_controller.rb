class Shop::ReviewsController < ::ApplicationController
  def new
    @review = Review.new(book: Book.find(params[:book_id]))
  end
end
