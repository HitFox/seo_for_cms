# Custom JS for the admin area
$ ->
  $('.result_url').click (event) ->
    event.preventDefault()
    $('.result_attributes').hide()
    $(this).next().toggle()
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
