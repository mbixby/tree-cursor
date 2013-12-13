# TreeSearch.TreeCursor
# Memoization
# 
# Methods for invalidating and inspecting property cache
# TODO More detailed documentation
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
      # TODO Review
      @resetProperties @_baseChildrenProperties

  resetProperties: (keys) ->
    Ember.changeProperties =>
      # Ember.Object#propertyDidChange notifies all listeners about a change
      # in the property. This effectively clears the memoized values and calls
      # the underlying getter, if neccessary.
      # This method would not work for regular properties (attributes) on this 
      # object because #propertyDidChange only works if the ComputedProperty 
      # is properly set up. Since the ComputedProperty does not ensure this 
      # behavior, #propertyDidChange works in general case only
      # with TogglableComputedProperty. See TogglableComputedProperty class
      # for more info.
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
