class CartController < ApplicationController

  after_action :save_order_for_progress, unless: [:show]

  def show
  end

  def add_item
    cart_item =  @order.cart_items.find { |item| item.book_id == cart_params[:book_id].to_i} ||
                 @order.cart_items.new(book_id: cart_params[:book_id], book_count: 0)
    cart_item.book_count += cart_params[:book_count].to_i
    redirect_to :back
  end

  def update_item
    cart_item =  @order.cart_items.find { |item| item.book_id == cart_params[:book_id].to_i}
    cart_item.book_count = cart_params[:book_count]
    @cart_item = cart_item
    respond_to do |format|
      format.json
    end
  end

  def remove_item
    cart_item =  @order.cart_items.find { |item| item.book_id == params[:id].to_i}
    @order.cart_items.delete(cart_item)
    redirect_to :back
  end

  def destroy
    @order.carts = []
    redirect_to :back
  end

  protected

  def save_order_for_progress
    if @order.persisted?
      @order.update!
    else
      session[:cart_items] = @order.cart_items
    end
  end

  def cart_params
    params.require(:cart).permit(:book_id, :book_count)
  end
end
