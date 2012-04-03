class Backbone.FilterableCollection extends Backbone.Collection
  initialize: (options) ->
    @isFiltered = true

  reset: (models, options) =>
    # make super reset silent if we are going to filter afterwards:
    opts = options ? {}
    if @filters? and not options?.skipFilter
      opts.silent = true
    super models, opts

    @filter() unless options?.skipFilter

  addFilter: (filter, options) ->
    @filters or= []
    @filters.push filter
    @reset @unfiltered, options

  removeFilter: (filter, options) ->
    @filters = _.reject @filters, (f) => f is filter
    @reset @unfiltered, options

  toggleFilters: ->
    # This code is a bit of a doozy.
    # Since this is a toggle method, we assign "not @isFiltered to @isFiltered"
    @isFiltered = not @isFiltered
    @reset @unfiltered, {skipFilter: not @isFiltered} # inverse @isFiltered to determine filtering

  clearFilters: ->
    @filters = []
    @reset @unfiltered, {skipFilter: true}

  filter: ->
    @unfiltered = @filtered = @models
    return unless @filters?
    # Reset the collection with a new set of models.
    # -> This set of models is delivered by making a selection (@select) of the original models.
    # --> The selection is based on an array of filter- functions that all have to be 'true'.
    # ---> These functions are squashed into one Boolean by reducing (@reduce) the array.
    # ----> The reduce function gets 2 parameters: a memo and a Boolean.
    # -----> This Boolean is delivered by the current function from the array.
    @filtered = @select (model) => @filters.reduce(( (memo, filter) -> memo and filter(model) ), true)
    @reset @filtered, {skipFilter: true}

  filteredCount: ->
    @unfiltered?.length - @filtered?.length