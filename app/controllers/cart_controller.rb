class CartController < ApplicationController
  before_action :define_order_in_progress

  def show

  end

  def update

  end

  def add
    existing_cart_item =  @order.cart_items.find { |item| item.book_id == params[:cart][:book_id].to_i} ||
                          @order.cart_items.new(book_id: params[:cart][:book_id], book_count: 0)
    existing_cart_item.book_count += params[:cart][:book_count].to_i
    if @order.persisted?
      @order.update!
    else
      session[:cart_items] = @order.cart_items
    end
    redirect_to :back
  end

  def destroy

  end
end
