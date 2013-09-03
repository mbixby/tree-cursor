# TreeSearch.Traversable
# By applying the mixin into a node class, the class gains all the navigation
# properties from TreeCursor, while cursors itself stay abstracted away.
# 
# @example
# ```
# Node = Ember.Object.extend TreeSearch.Traversable
#   # @private
#   findParentNode: ...
#   # @private
#   findChildNodes: ...
#   
# node = Node.create()
# node.get 'parent' #=> now returns memoized parent
# ```

TreeSearch.Traversable = Ember.Mixin.create
  
  # Pointer to this node
  # @type TreeSearch.TreeCursor
  cursor: (->
    (@get 'cursorClass').create node: this
  ).property()
  
  # You can provide your own TreeCursor subclass
  # @abstract
  cursorClass: TreeSearch.TreeCursor

  # Aliases public navigation properties from TreeCursor
  # and returns the actual node, not cursor. Note that nearly all
  # such properties are read-only.
  unknownProperty: (key) ->
    value = @get "cursor.#{key}"
    if value instanceof TreeSearch.TreeCursor
      value.get 'node'
    else if value[0] and value[0] instanceof TreeSearch.TreeCursor
      value.mapProperty 'node'
    else
      value

  setUnknownProperty: (key, value) ->
    cursor = value.get 'cursor' if value.get?
    @set "cursor.#{key}", cursor if cursor instanceof TreeSearch.TreeCursor