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
  dirtyCursor: ->
    @reset()

  # @public
  dirtySubtree: ->
    cursor.dirtySubtree() for cursor in @get 'children'
    @dirtyCursor()

  # @public
  dirtyChildren: ->
    cursor.dirtySubtree() for cursor in @get 'children'
    # TODO This doesn't look well
    @_clearCacheOfProperty key for key in ['firstChild', '_children']

  # Resets cursor with new properties. Can be used instead of this.copy
  # for performance reasons (to repurpose cursors).
  # TODO Decouple tree-wide (#isVolatile) from cursor-specific
  # configuration for straightforward removal of cursor-specific residue.
  # 
  # @param {Array ([String])} preserved keys of preserved properties
  reset: (preserved = ['root'], properties = {}) ->
    Ember.changeProperties =>
      keys = @get '_namesOfCursorSpecificProperties'
      keys = keys.reject (key) -> preserved.contains key
      @_clearCacheOfProperty key for key in keys
      @set key, value for key, value of properties
      this

  # Constructs an object with memoized properties from the current
  # cursor. This can be passed to @create to preserve memoized properties
  # on the next cursor
  # @returns Object
  _memoizedPropertiesForKeys: (propertyList = []) ->
    keysAndValues = propertyList.map (key) => 
      value = if @[key] isnt undefined
        @[key]
      else
        @cacheFor key
      [key, value] if value isnt undefined
    _.zipObject _.compact keysAndValues

  # Important: the list contains only properties that were have been set 
  # (via @set) on this object
  _namesOfCursorSpecificProperties: (->
    _.compact @eachComputedProperty (name, meta) -> 
      name if meta.cursorSpecific
  ).property().volatile()

  _getDescriptorOfProperty: (name) ->
    prototype = @proto()
    descriptors = (Ember.meta prototype).descs
    descriptors[name]

  _clearCacheOfProperty: (name) ->
    descriptor = Ember.meta @_getDescriptorOfProperty name
    delete meta.cache[keyName] if descriptor._cacheable

  # Allows to peek at property cache. Unlike @cacheFor, this also looks
  # at keys defined on this object
  _cachedOrDefinedProperty: (name) ->
    value = @[name]
    if value is undefined
      value = @cacheFor name
    value

  _isPropertyCachedOrDefined: (name) ->
    undefined isnt @_cachedOrDefinedProperty name

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
