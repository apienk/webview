define [
  'jquery'
  'backbone'
  'cs!router'
], ($, Backbone, router) ->

  # The root URI prefixed on all non-external AJAX and Backbone URIs
  root = '/'

  init = (options = {}) ->
    # Append /test to the root if the app is in test mode
    if options.test
      root += 'test/'

    external = new RegExp('^((f|ht)tps?:)?//')

    # Catch internal application links and let Backbone handle the routing
    $(document).on 'click', 'a:not([data-bypass])', (e) ->
      href = $(this).attr('href')

      # Don't handle navigation if the default handling was already prevented
      if e.isDefaultPrevented() or href.charAt(0) is '#' then return

      e.preventDefault()

      if external.test(href)
        window.open(href, '_blank')
      else
        router.navigate(href, {trigger: true})

    Backbone.history.start
      pushState: true
      root: root

    # Prefix all non-external AJAX requests with the root URI
    $.ajaxPrefilter ( options, originalOptions, jqXHR ) ->
      if not external.test(options.url)
        options.url = root + options.url

      return

  return {init: init}