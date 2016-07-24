# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  console.log "cart"
  $('.cart_item_count input').change ->
    current_row = $(this).parents(".cart_item")
    console.log $(this).val()
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
