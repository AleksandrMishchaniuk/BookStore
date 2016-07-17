class PagesController < ApplicationController

  def home
    @books = Book.bestsellers 3
  end

end
