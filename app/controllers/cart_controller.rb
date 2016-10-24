# :nodoc:
class CartController < ApplicationController
  after_action :save_order_for_progress, except: [:show]

  def show; end

  def add_item
    @cart_item = @order.find_or_build_cart_item(cart_params[:book_id])
    @cart_item.book_count += cart_params[:book_count].to_i
    redirect_to :back
  end

  def update_item
    @cart_item = @order.cart_item(cart_params[:book_id])
    @cart_item.book_count = cart_params[:book_count] if @cart_item
    respond_to do |format|
      format.json
    end
  end

  def remove_item
    @cart_item = @order.cart_item(params[:id])
    if @cart_item
      @cart_item.destroy if @cart_item.persisted?
      @order.cart_items.delete(@cart_item)
    end
    order_destroy if @order.cart_items.empty?
    redirect_to :back
  end

  def destroy
    order_destroy
    redirect_to :back
  end

  def update_coupon
    error = nil
    coupon = Coupon.find_by(code: params[:coupon])
    @order.set_coupon(coupon) || error = t('views.cart.msg.coupon_error')
    redirect_to cart_path, alert: error
  end

  protected

  def save_order_for_progress
    @order.save_by_strategy
  end

  def order_destroy
    @order.destroy_by_strategy
  end

  def cart_params
    params.require(:cart).permit(:book_id, :book_count)
  end
end
