define (require) ->
  BaseView = require('cs!helpers/backbone/views/base')
  SearchHeaderView = require('cs!../header/header')
  SearchResultsFilterView = require('cs!./filter/filter')
  SearchResultsBreadcrumbsView = require('cs!./breadcrumbs/breadcrumbs')
  SearchResultsListView = require('cs!./list/list')
  template = require('hbs!./results-template')
  require('less!./results')

  return class SearchResultsView extends BaseView
    template: template

    initialize: (options = {}) ->
      super()

      if not options.results
        throw new Error('A search results view must be instantiated with search results')

      @results = options.results

    regions:
      header: '.header'
      filter: '.filter'
      breadcrumbs: '.breadcrumbs'
      list: '.list'

    onRender: () ->
      @regions.header.show(new SearchHeaderView({model: @results}))
      @regions.filter.show(new SearchResultsFilterView({model: @results}))
      @regions.breadcrumbs.show(new SearchResultsBreadcrumbsView({model: @results}))
      @regions.list.show(new SearchResultsListView({model: @results}))