# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  calculate_order_total = ->
    delivery_price = parseFloat($(this).attr('data-price'))
    item_total = parseFloat($('.item_total span.price').html())
    $('.order_shipping span.price').html(delivery_price.toFixed(2))
    order_total = delivery_price + item_total
    $('.order_total span.price').html(order_total.toFixed(2))

  $('[name="order[delivery]"]').click(calculate_order_total)
  $('[name="order[delivery]"]:checked').click()
