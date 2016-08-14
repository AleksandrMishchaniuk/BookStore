# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('.cart_item_count input').change ->
    current_row = $(this).parents(".cart_item")
    data =
      cart:
        book_id: current_row.attr('data-book_id')
        book_count: $(this).val()
    $.ajax
      url: "/cart/update_item.json"
      method: 'POST'
      data: data
      dataType: 'json'
      success: (data)->
        current_row.find('.cart_item_total_price span').html(data['item_total'])
        $('.items_total span').html(data['items_total'])
        $('.items_discount span').html(data['items_discount'])
        $('.items_total_with_discount span').html(data['items_total_with_discount'])
