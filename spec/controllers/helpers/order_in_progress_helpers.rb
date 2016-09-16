module OdrderInProgressHelpers
  def order_from_session_by_cart_items
    order = build(:order)
    storage = Storage.new(controller, OrderFactory::STORAGE_KEY)
    storage[OrderFactory::NOT_PERSISTED_KEY] = order.cart_items.map { |item| item.attributes }
    order
  end

  def order_by_id_from_session
    order = create(:order)
    storage = Storage.new(controller, OrderFactory::STORAGE_KEY)
    storage[OrderFactory::PERSISTED_KEY] = order.id
    order.reload
  end

  def order_by_current_user
    order = create(:order_in_progress)
    user = create(:user)
    user.orders << order
    sign_in user
    order.reload
  end
end
