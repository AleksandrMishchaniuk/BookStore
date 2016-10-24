module Shop
  # :nodoc:
  class CategoriesController < ::ApplicationController
    def show
      @category = Category.find(params[:id])
      @books = @category.books.page(params[:page]).per(6)
    rescue
      redirect_to shop_books_path
    end
  end
end
