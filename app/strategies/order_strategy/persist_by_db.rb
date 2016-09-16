class OrderStrategy::PersistByDb < OrderStrategy::PersistBase

  def save(order)
    prepare(order)
    order.save_with_cart_items
  end

  def destroy(order)
    prepare_destroy(order)
    unless order.cart_items.empty?
      order.cart_items.each { |item| item.destroy! }
    end
    order.destroy!
    order.cart_items.delete_all
  end

end
