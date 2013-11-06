# TreeSearch.TreeCursor
# Configuration
# 
# Implement these methods to define basic logic for retrieval 
# of adjacent nodes. Please mind the type signature.
# See Helpers.Node for a specific example.
# 
# Important: You should not return multiple objects representing the same
# node (one node => one Javascript object). Object equality is used
# to check whether two nodes belong to the same tree. See
# TreeCursor#cursorPool for more info.
# 
# (These methods are defined on TreeCursor and not on Node as to not
# pollute your Node class with navigation logic.)

TreeSearch.TreeCursor.reopen
  
  # Should return `null` if the parent does not exist (not `undefined`).
  # 
  # Note that without this accessor, any child node will have no way 
  # to independently look up their parent if the child node wasn't derived
  # from root.
  # By referencing parent from each node, each node represents the whole
  # tree, not just its own subtree.
  # 
  # @example
  # ```
  #   findParentNode: (node) -> node.parentNode
  # ```
  # @protected
  # @type Function (-> Object | null)
  findParentNode: undefined

  # Returns an empty array if there aren't any children (not `null`)
  # @example
  # ```
  #   findChildNodes: (node) -> node.childNodes
  # ```
  # @protected
  # @type Function (-> Array(Object))
  findChildNodes: undefined

  # Returns `null` if the parent does not exist (not `undefined`).
  # @protected
  # @type Function (-> Object)
  findFirstChildNode: undefined

  # Returns `null` if the parent does not exist (not `undefined`).
  # @protected
  # @type Function (-> Object)
  findRightSiblingNode: undefined

  # Returns `null` if the parent does not exist (not `undefined`).
  # @protected
  # @type Function (-> Object)
  findLeftSiblingNode: undefined

  # If #findChildNodes is available in place of #findFirstChildNode 
  # and #findRightSiblingNode, #findFirstChildNode is transformed 
  # into the latter.
  # Note that nodes can be equal, cursors are unique.
  # TODO Review, Test perf. (?)
  _translateChildNodesAccessor: ->
    if @findChildNodes
      @findFirstChildNode ?= @_firstObjectInChildNodes
      @findRightSiblingNode ?= @_rightSiblingInChildNodes
      @findLeftSiblingNode ?= @_leftSiblingInChildNodes

  _firstObjectInChildNodes: ->
    @get '_childNodes.firstObject'

  _rightSiblingInChildNodes: ->
    (@get 'parent._childNodes')?.objectAt (@get '_indexInSiblingNodes') + 1

  _leftSiblingInChildNodes: ->
    (@get 'parent._childNodes')?.objectAt (@get '_indexInSiblingNodes') - 1

  # Memoized childNodes if #findChildNodes is available
  _childNodes: (-> 
    @findChildNodes @node
  ).togglableProperty()

  # Index in #_childNodes
  # TODO Remove, preload
  _indexInSiblingNodes: (-> 
    if @node is _.head @get 'parent._childNodes'
      0 
    else
      if @isPropertyMemoized 'leftSibling'
        (@get 'leftSibling._indexInSiblingNodes') + 1
      else
        (@get 'parent._childNodes').indexOf @node
  ).togglableProperty()
  