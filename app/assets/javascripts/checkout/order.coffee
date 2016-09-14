# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

  toggle_shipping_address = ->
    if $(this).prop('checked')
      $('[name ^= "order[shipping]"]').attr('disabled', 'true')
                                      .parents('.form-group').hide()
    else
      $('[name ^= "order[shipping]"]').removeAttr('disabled')
                                      .parents('.form-group').show()

  $('#once_address').change(toggle_shipping_address).change()
