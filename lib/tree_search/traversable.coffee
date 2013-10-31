# TreeSearch.Traversable
# 
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
# 
# The tree is defined by root node's #cursor (all cursors will share 
# its cursorPool)

TreeSearch.Traversable = Ember.Mixin.create

  # Aliases public navigation properties from TreeCursor
  # and returns the actual node, not cursor. Note that nearly all
  # such properties are read-only.
  unknownProperty: (key) ->
    if ['rootNode', 'cursorClass'].contains key
      return
    value = @get "cursor.#{key}"
    if value instanceof TreeSearch.TreeCursor
      value.get 'node'
    else if value?[0] and value?[0] instanceof TreeSearch.TreeCursor
      value.mapProperty 'node'
    else
      value

  # setUnknownProperty: (key, value) ->
  #   cursor = value.get 'cursor' if value?.get?
  #   only if cursor responds to key...
  #     @set "cursor.#{key}", cursor if cursor instanceof TreeSearch.TreeCursor
  #   else
  #     @set key, value
  
  # Pointer to this node
  # @type TreeSearch.TreeCursor
  cursor: (->
    cursor = (@get 'cursorClass').create node: this
    rootNode = (@get 'rootNode') ? cursor.get 'root.node'
    if this is rootNode
      cursor
    else
      cursor.copyIntoTree rootNode.get 'cursor'
  ).property()

  # Optional direct link to root node
  # @see #cursor
  rootNode: undefined
  
  # You can provide your own TreeCursor subclass
  # @abstract
  cursorClass: TreeSearch.TreeCursor