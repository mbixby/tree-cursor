# TreeSearch.TreeCursor
# Memoization
# 
# Property (attribute of type Ember.ComputedProperty) marked 
# as 'cursorSpecific' implies that the property contains information about
# adjacent cursors.
# Such property is not memoized when the tree is volatile 
# (i.e. #isVolatile is set to true). Its cache is also automatically
# cleared when the cursor is reset or copied.
# 
# Example of property definition:
# ```
# key: (->
#   # accessor logic
# ).property('dependency').meta(cursorSpecific: yes)
# ```

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

  _getDescriptorOfProperty: (name) ->
    prototype = @constructor.proto()
    descriptors = (Ember.meta prototype).descs
    descriptors[name]

  _clearCacheOfProperty: (name) ->
    descriptor = @_getDescriptorOfProperty name
    if descriptor._cacheable
      meta = Ember.meta this, true
      delete meta.cache[name]

  didChangeTreeVolatility: (->
    isVolatile = @get 'isVolatile'
    wasVolatile = @_previousValueOfIsVolatile
    @_previousValueOfIsVolatile = isVolatile

    for key in @get '_namesOfCursorSpecificProperties'
      descriptor = @_getDescriptorOfProperty key

      # Volatile properties should always stay volatile
      if (not wasVolatile) and not descriptor._cacheable
        Ember.setMeta descriptor, 'shouldStayVolatile', yes 

      # Toggle volatility and clear caches
      unless Ember.getMeta descriptor, 'shouldStayVolatile'
        descriptor.cacheable not isVolatile
        @propertyDidChange name unless isVolatile
  ).observes 'isVolatile'

  _previousValueOfIsVolatile: no
