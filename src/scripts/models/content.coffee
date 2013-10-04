define (require) ->
  $ = require('jquery')
  _ = require('underscore')
  Backbone = require('backbone')
  settings = require('cs!settings')
  require('backbone-associations')

  MEDIA_TYPES =
    'application/vnd.org.cnx.collection' : 'book'
    'application/vnd.org.cnx.module': 'page'

  CONTENT_URI = "#{location.protocol}//#{settings.cnxarchive.host}:#{settings.cnxarchive.port}/contents"

  class Node extends Backbone.AssociatedModel
    url: () -> "#{CONTENT_URI}/#{@id}"
    defaults:
      title: 'Untitled'
      authors: []
      content: 'No content'

    parse: (response, options) ->
      if not response.content then return response
      # jQuery can not build a jQuery object with <head> or <body> tags,
      # and will instead move all elements in them up one level.
      # Use a regex to extract everything in the body and put it into a div instead.
      $body = $('<div>' + response.content.replace(/^[\s\S]*<body.*?>|<\/body>[\s\S]*$/g, '') + '</div>')
      $body.find('.title').eq(0).remove()
      response.content = $body.html()

      return response

    relations: [{
      type: Backbone.Many
      key: 'contents'
      relatedModel: Node
    }]

    findPage: (num) ->
      search = (item) ->
        contents = item.get('contents')
        for item in contents.models
          if item.get('page') is num
            return item
          else if item.get('contents')
            result = search(item)
            return result if result
        return

      return search(@)

  return class Content extends Backbone.AssociatedModel
    url: () -> "#{CONTENT_URI}/#{@id}"

    defaults:
      title: 'Untitled Book'
      pages: 1
      authors: []

    relations: [{
      type: Backbone.One
      key: 'tree'
      relatedModel: Node
    }, {
      type: Backbone.Many
      key: 'authors'
      collectionType: Backbone.Collection
    }]

    toJSON: () ->
      currentPage = @get('currentPage')?.toJSON()
      toc = @get('toc').toJSON()
      json = super()
      json.currentPage = currentPage
      json.toc = toc
      return json

    parse: (response) ->
      type = MEDIA_TYPES[response.mediaType]
      toc = @get('toc')
      @set('type', type)

      if type isnt 'book' then return response

      depth = 0
      page = 1

      traverse = (o = {}, sub) =>
        for item, index in o.contents
          item.book = @
          item.depth = depth

          if depth
            item.parent = o
            item.unit = "#{o.unit}-#{index+1}"
          else
            item.unit = "#{index+1}"

          if item.contents
            item.subcollection = true
            delete item.id
            depth++
            traverse(item, true)
          else
            item.page = page++

        depth--

      traverse(response.tree)

      @set('pages', page-1)

      return response

    initialize: (options = {}) ->
      @set('toc', new Backbone.Collection())
      @fetch
        success: () => @load(options.page)

    load: (page) ->
      if @get('type') is 'book'
        toc = @get('toc')
        for i in [0..@get('pages')] by 1
          toc.add(@findPage(i+1))

        @setPage(page or 1) # Default to page 1
      else
        @set('currentPage', new Node({id: @id}))
        @get('currentPage').fetch()

    findPage: (num) ->
      @get('tree').findPage(num)

    setPage: (num) ->
      if num < 1 then num = 1
      if num > @pages then num = @pages
      if not num then return

      @set('page', num)

      window.x = @
      page = @get('toc').at(num-1)
      @get('currentPage')?.set('active', false)
      @set('currentPage', page)
      page.set('active', true)

      if not page.loaded
        page.fetch
          success: () -> page.loaded = true

    nextPage: () ->
      currentPage = @get('currentPage')
      page = @get('page')

      # Show the next page if there is one
      if page < @get('pages')
        @setPage(++page)

      return page

    previousPage: () ->
      currentPage = @get('currentPage')
      page = @get('page')

      # Show the previous page if there is one
      if page isnt 1
        @setPage(--page)

      return page
