class CartController < ApplicationController

  after_action :save_order_for_progress, except: [:show]

  def show
  end

  def add_item
    @cart_item =  @order.cart_items.find { |item| item.book_id == cart_params[:book_id].to_i} ||
                 @order.cart_items.new(book_id: cart_params[:book_id], book_count: 0)
    @cart_item.book_count += cart_params[:book_count].to_i
    redirect_to :back
  end

  def update_item
    @cart_item =  @order.cart_items.find { |item| item.book_id == cart_params[:book_id].to_i}
    @cart_item.book_count = cart_params[:book_count]
    respond_to do |format|
      format.json
    end
  end

  def remove_item
    @cart_item =  @order.cart_items.find { |item| item.book_id == params[:id].to_i}
    @cart_item.destroy if @cart_item.persisted?
    @order.cart_items.delete(@cart_item)
    order_destroy if @order.cart_items.empty?
    redirect_to :back
  end

  def destroy
    order_destroy
    redirect_to :back
  end

  protected

  def save_order_for_progress
    @order.save_to_progress if @order.persisted?
  end

  def order_destroy
    @order.delete_from_progress if @order.persisted?
    @order.cart_items.delete_all
  end

  def cart_params
    params.require(:cart).permit(:book_id, :book_count)
  end
end
