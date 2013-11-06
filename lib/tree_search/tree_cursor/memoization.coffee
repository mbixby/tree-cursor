# TreeSearch.TreeCursor
# Memoization
# 
# Methods for invalidating and inspecting property cache
# @see TogglableComputedProperty

TreeSearch.TreeCursor.reopen
  
  # Dirtying a node will clean its memoized properties (cached information
  # about its neighbors)
  # @public
  resetCursor: ->
    @resetProperties @_baseNeighborProperties

  # @public
  resetSubtree: ->
    Ember.changeProperties =>
      cursor.resetSubtree() for cursor in @get 'children'
      @resetCursor()

  # @public
  resetChildren: ->
    Ember.changeProperties =>
      cursor.resetSubtree() for cursor in @get 'children'
      # TODO This doesn't look well
      @resetProperties @_baseChildrenProperties

  resetProperties: (keys) ->
    Ember.changeProperties =>
      @propertyDidChange key for key in keys

  # Constructs an object with memoized properties from the current
  # cursor. This can be passed to @create to preserve memoized properties
  # on the next cursor
  # @returns Object
  getMemoizedProperties: (propertyList = []) ->
    _.zipObject _.compact propertyList.map (key) => 
      value = @getMemoized key
      [key, value] if value isnt undefined
    
  # Allows to peek at property cache. Unlike @cacheFor, this also looks
  # at keys defined on this object.
  # TODO Comment about undefined vs null
  getMemoized: (propertyName) ->
    value = @[propertyName]
    if value is undefined
      value = @cacheFor propertyName
    value

  isPropertyMemoized: (propertyName) ->
    undefined isnt @getMemoized propertyName

  # Neighbors from which other properties are inferred
  # TODO Remove
  _baseNeighborProperties: ['parent', 'firstChild', 'rightSibling', 'leftSibling', '_childNodes', '_indexInSiblingNodes']
  
  _baseChildrenProperties: ['firstChild', '_childNodes', '_indexInSiblingNodes']

  _clearCacheOfProperty: (name) ->
    descriptor = @_getDescriptorOfProperty name
    if descriptor._cacheable
      meta = Ember.meta this, true
      delete meta.cache[name]

  _getDescriptorOfProperty: (name) ->
    prototype = TreeSearch.TreeCursor.proto()
    descs = (Ember.meta prototype).descs
    descs[name]
