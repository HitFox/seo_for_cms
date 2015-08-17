# Custom JS for the admin area

$ ->
  $('.result_url').click (event) ->
    event.preventDefault()
    clone = $(this).next().clone()
    $(this).siblings().removeClass('result_attr_show_me')
    $(this).siblings().removeClass('result_attr_hide_me')
    if clone.hasClass('result_attr_show_me') then $(this).next().addClass('result_attr_hide_me') else $(this).next().addClass('result_attr_show_me');
    $('.result_url_value').hide()
    return
  return

$ ->
  $('.result_url_name').click (event) ->
    event.preventDefault()
    $(this).next().toggle()
    return
  return

$ ->
  $('.url_show').click (event) ->
    event.preventDefault()
    $(this).next().toggle()
    return
  return
