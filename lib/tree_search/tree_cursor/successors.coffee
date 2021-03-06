# TreeSearch.TreeCursor
# Successors
# 
# Notable properties:
# * `successor`
# * `predecessor`
# * `successorAtSameDepth` (non-reactive)
# * `predecessorAtSameDepth` (non-reactive)
#   
# Definitions of properties below should be implied by their declaration
# (implementation)

TreeSearch.TreeCursor.reopen

  # @type TreeCursor | null    
  # @readonly
  upwardSuccessor: (->
    (@get 'parent.rightSibling') ?
    (@get 'parent.upwardSuccessor')
  ).togglableProperty('parent.rightSibling', 'parent.upwardSuccessor')

  # @type TreeCursor | null    
  # @readonly
  upwardPredecessor: (->
    (@get 'parent.leftSibling') ?
    (@get 'parent.upwardPredecessor')
  ).togglableProperty('parent.leftSibling', 'parent.upwardPredecessor')

  # Note that retrieving successors recursively starting at root
  # would traverse the whole tree.
  # 
  # @type TreeCursor | null
  # @readonly
  successor: (->
    (@get 'firstChild') ?
    (@get 'rightSibling') ?
    (@get 'upwardSuccessor')
  ).togglableProperty('firstChild', 'rightSibling', 'upwardSuccessor')

  # Examples:
  # 
  # ```
  #  (predecessor) 4. /\ 3.
  #                      \ 2.
  #                        \ 1. (this)
  # ```                    
  # 
  # ```
  #                  3. /\ 2.
  #  (predecessor) 4. /    \ 1. (this)
  # ```  
  # 
  # ```
  #         1. (this)
  #        /|\ 2. (predecessor)
  #      /  |  \ x. (not visited; predecessor's predecessor)
  # ```     
  # 
  # Note that retrieving predecessors recursively starting at root
  # would traverse the whole tree.
  # 
  # @type TreeCursor | null
  # @readonly
  predecessor: (->
    (@get 'lastChild') ?
    (@get 'leftSibling') ?
    (@get 'upwardPredecessor')
  ).togglableProperty('lastChild', 'leftSibling', 'upwardPredecessor')

  # @private
  # @param {Number} depth
  findCursorAndItsRelativeDepth: (propertyName, depth = 0) ->
    cursor = @get propertyName
    if cursor
      [cursor, Math.abs depth - cursor.get 'depth']
    else
      null

  # Get next successors until we find one at a specified depth (relative 
  # to root)
  # TODO Depth should be relative to self (see file history)
  # 
  # @public
  # @param targetDepth (!) absolute depth starting at 0 (root)
  # @type Function (number -> TreeCursor)
  findSuccessorAtDepth: (targetDepth, currentDepth) ->
    # If the successor is at lower depth than this node, we should 
    # walk back up the tree by retrieving upwardSuccessor instead of
    # successor. We don't need to visit any lower subtrees.
    succ = if targetDepth < (currentDepth ? @get 'depth')
      (@get 'rightSibling') ?
      (@get 'upwardSuccessor')
    else
      (@get 'successor')
    successorDepth = succ?.get 'depth'
    if targetDepth is successorDepth
      succ
    else
      succ?.findSuccessorAtDepth targetDepth, successorDepth

  # @public
  # @param targetDepth (!) absolute depth starting at 0 (root)
  # @type Function (number -> TreeCursor)
  findPredecessorAtDepth: (targetDepth, currentDepth) ->
    pred = if targetDepth < (currentDepth ? @get 'depth')
      (@get 'leftSibling') ?
      (@get 'upwardPredecessor')
    else
      (@get 'predecessor')
    predecessorDepth = pred?.get 'depth'
    if targetDepth is predecessorDepth
      pred
    else
      pred?.findPredecessorAtDepth targetDepth, predecessorDepth

  # @readonly
  # @type TreeCursor | null
  # TODO Make reactive
  successorAtSameDepth: (->
    @findSuccessorAtDepth @get 'depth'
  ).togglableProperty().volatile()

  # @readonly
  # @type TreeCursor | null
  # TODO Make reactive
  predecessorAtSameDepth: (->
    @findPredecessorAtDepth @get 'depth'
  ).togglableProperty().volatile()

  # @readonly
  # @type TreeCursor | null
  leafSuccessor: (->
    if succ = @get "successor"
      if succ.get "isLeaf" then succ 
      else succ.get "leafSuccessor"
    else
      null
  ).togglableProperty('successor', 'successor.isLeaf', 'successor.leafSuccessor')

  # @readonly
  # @type TreeCursor | null
  leafPredecessor: (->
    if pred = @get "predecessor"
      if pred.get "isLeaf" then pred 
      else pred.get "leafPredecessor"
    else
      null
  ).togglableProperty('predecessor', 'predecessor.isLeaf', 'predecessor.leafSuccessor')

  # @type Array ([TreeCursor])
  # @readonly
  successors: (->
    succ = Ember.makeArray @get 'successor'
    succ.concat Ember.makeArray @get 'successor.successors'
  ).togglableProperty('successor', 'successor.successors')
