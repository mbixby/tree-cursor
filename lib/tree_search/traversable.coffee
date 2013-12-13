require 'tree_search/tree_cursor/*'

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
# 
# List of read-only public properties aliased from TreeCursor:
# 
# * branch
# * children
# * depth
# * firstChild
# * firstChildFromLeft
# * firstChildFromRight
# * height
# * isLeaf
# * isRoot
# * lastChild
# * leafPredecessor
# * leafSuccessor
# * leftLeafSuccessor
# * leftSibling
# * leftSiblings
# * leftSuccessor
# * leftSuccessorAtSameDepth
# * leftmostSibling
# * parent
# * predecessor
# * predecessorAtSameDepth
# * rightLeafSuccessor
# * rightSibling
# * rightSiblings
# * rightSuccessor
# * rightSuccessorAtSameDepth
# * rightmostSibling
# * root
# * successor
# * successorAtSameDepth
# * twinFromOriginalTree
# * upwardPredecessor
# * upwardSuccessor
# * validations

# Retrieves a list of properties to be mixed in by TreeSearch.Traversable.
# This list equals to all properties of TreeCursor that have a type
# of `TogglableComputedProperty`.
cursorProperties = do ->
  meta = Ember.meta TreeSearch.TreeCursor.proto(), false
  _.compact _.map meta.descs, (property, name) -> 
    name if property instanceof TogglableComputedProperty

cursorAlias = (propertyName) ->
  dependentKey = "cursor.#{propertyName}"
  Ember.computed dependentKey, (key) ->
    if arguments.length isnt 1
      Ember.warn "Properties from TreeCursor.Traversable mixin are read-only."
    result = @get dependentKey
    if result instanceof TreeSearch.TreeCursor
      result.get 'node'
    else if result?[0] and result?[0] instanceof TreeSearch.TreeCursor
      result.mapProperty 'node'
    else
      result

# Maps cursor properties to ComputedProperty aliases 
# from TreeSearch.Traversable to TreeCursor
aliases = _.zipObject cursorProperties.map (name) -> 
  [name, cursorAlias name]

TreeSearch.Traversable = Ember.Mixin.create Ember.merge aliases,
  
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

  # @param {Object} node
  # @returns {Object} node
  # @see findChildBelongingBranchOfCursor
  findChildBelongingBranchOfNode: (node) ->
    ret = (@get 'cursor').findChildBelongingToBranchOfCursor node.get 'cursor'
    ret?.get 'node'
  