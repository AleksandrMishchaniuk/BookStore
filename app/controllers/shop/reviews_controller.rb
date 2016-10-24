module Shop
  # :nodoc:
  class ReviewsController < ::ApplicationController
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
      return render :new unless @review.save
      redirect_to shop_book_path(params[:book_id]),
                  notice: t('views.shop.review_notice')
    rescue
      redirect_to :back
    end

    protected

    def review_params
      params.require(:review).permit(:title, :text, :vote)
    end
  end
end
