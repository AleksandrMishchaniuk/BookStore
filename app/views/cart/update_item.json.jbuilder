json.item_total "%.02f" % @cart_item.total_price
json.items_total "%.02f" % @order.item_total
json.items_discount "%.02f" % @order.item_discount
json.items_total_with_discount "%.02f" % @order.item_total_with_discount
