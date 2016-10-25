module OrderStrategy
  # :nodoc:
  class PersistByDb < PersistBase
    def save(order)
      prepare(order)
      order.save_with_cart_items
    end

    def destroy(order)
      prepare_destroy(order)
      order.destroy!
      order.cart_items.delete_all
    end

    def get_coupon(order)
      prepare(order)
      check_coupon_storage(order)
      order.coupon
    end

    def set_coupon(order, coupon)
      prepare(order)
      check_coupon_storage(order)
      return coupon if coupon == order.coupon
      prepare_set_coupon(order, coupon)
      order.coupon = coupon
    end

    protected

    def check_coupon_storage(order)
      return unless @coupon_storage[@coupon_key]
      order.coupon = Coupon.find(@coupon_storage[@coupon_key])
      @coupon_storage[@coupon_key] = nil
    end
  end
end
