# TreeSearch.TreeCursor
# Configuration
# 
# Implement these methods to define basic logic for retrieval 
# of adjacent nodes. Please mind the type signature.
# See TreeCursor class in DOMUtilities component for an example.
# 
# Note: These are defined on TreeCursor and not on Node as to not
# pollute your Node class with navigation logic.

TreeSearch.TreeCursor.reopen
  
  # @example
  # ```
  #   findParentNode: -> (jQuery (@get 'node')).children()
  # ```
  # @protected
  # Returns `null` if the parent does not exist (not `undefined`).
  # @type Function (-> Object | null)
  findParentNode: undefined

  # @example
  # ```
  #   findChildNodes: -> (@get 'node').childNodes
  # ```
  # @protected
  # Returns an empty array if there aren't any children (not `null`)
  # @type Function (-> Array(Object))
  findChildNodes: undefined

  # @protected
  # Returns `null` if the parent does not exist (not `undefined`).
  # @type Function (-> Object)
  findFirstChildNode: undefined

  # @protected
  # Returns `null` if the parent does not exist (not `undefined`).
  # @type Function (-> Object)
  findRightSiblingNode: undefined

  # @protected
  # Returns `null` if the parent does not exist (not `undefined`).
  # @type Function (-> Object)
  findLeftSiblingNode: undefined

  # If #findChildNodes is available in place of #findFirstChildNode 
  # and #findRightSiblingNode, #findFirstChildNode is transformed 
  # into the latter.
  # Note that nodes can be equal, cursors are unique.
  # TODO Review, Test perf. (?)
  _translateChildNodesAccessor: ->
    if @findChildNodes
      @findFirstChildNode ?= -> 
        @get '_childNodes.firstObject'
      @findRightSiblingNode ?= -> 
        (@get 'parent._childNodes').objectAt @get '_indexInSiblingNodes' + 1
      @findLeftSiblingNode ?= -> 
        (@get 'parent._childNodes').objectAt @get '_indexInSiblingNodes' - 1

  # Memoized childNodes if #findChildNodes is available
  _childNodes: (-> 
    @findChildNodes()
  ).property().meta cursorSpecific: yes
  
  # Index in #_childNodes
  # TODO Implement
  _indexInSiblingNodes: (-> 
    (@get 'parent._childNodes').indexOf @get 'node'
  ).property().meta cursorSpecific: yes
