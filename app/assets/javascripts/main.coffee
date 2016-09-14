$ ->
  $('.field_with_errors').parents('.form-group').addClass('has-error')
  $('.form-group label').parents('div.field_with_errors')
                        .css({display: 'inline'})
