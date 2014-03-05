define (require) ->
  _ = require('underscore')
  TocDraggableView = require('cs!./draggable')
  TocLeafView = require('cs!./leaf')
  template = require('hbs!./tree-template')
  require('less!./tree')

  return class TocTreeView extends TocDraggableView
    template: template
    templateHelpers:
      editable: () -> @editable
      expanded: () -> @model.expanded
    itemViewContainer: '> ul'

    events:
      'click > div > span > .subcollection': 'toggleSubcollection'
      'click > div > .remove': 'removeNode'

      # Drag and Drop events
      'dragstart > div': 'onDragStart'
      'dragenter > div': 'onDragEnter'
      'dragleave > div': 'onDragLeave'
      'drop > div': 'onDrop'

    initialize: () ->
      @content = @model.get('book') or @model
      @editable = @content.get('editable')
      @regions =
        container: @itemViewContainer

      super()
      @listenTo(@model, 'change:unit change:title change:subcollection', @render)

    onRender: () ->
      @regions.container.empty()

      nodes = @model.get('contents')?.models

      _.each nodes, (node) =>
        if node.get('subcollection')
          @regions.container.appendAs 'li', new TocTreeView
            model: node
        else
          @regions.container.appendAs 'li', new TocLeafView
            model: node
            collection: @model

    toggleSubcollection: (e) ->
      if @model.expanded
        @model.expanded = false
        @$el.children().removeClass('expanded')
      else
        @model.expanded = true
        @$el.children().addClass('expanded')

    removeNode: () ->
      @content.removeNode(@model)
