class Shop::ReviewsController < ::ApplicationController
  before_action :authenticate_user!
  authorize_resource

  def new
    @review = Review.new(book: Book.find(params[:book_id]))
  rescue
    redirect_to :back
  end

  def create
    book = Book.find(params[:book_id])
    @review = Review.new(review_params)
    @review.user = current_user
    @review.book = book
    if @review.save
      redirect_to shop_book_path(params[:book_id]), notice: 'You review will be shown after approved by admin'
    else
      render :new
    end
  rescue
    redirect_to :back
  end

  protected

  def review_params
    params.require(:review).permit(:title, :text, :vote)
  end
end
