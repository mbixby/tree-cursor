require 'tree_search/tree_cursor'
require 'tree_search/traversal_algorithms/*'

# TreeSearch
#
# Iteration over tree nodes with intent to collect and yield nodes that pass
# particular constraints. 
# 
# To use TreeSearch, you have to extend it first with your custom TreeCursor 
# implementation to define how to walk in your tree (from node to node).
# For examples on how to do this, see tests or other components 
# using TreeSearch.
# 
# Note that:
# * you can't change search parameters and constraints after you 
#   performed the search
# * consumers of TreeSearch will be exposed to tree nodes, not cursors

TreeSearch.Base = Ember.Object.extend().reopenClass
  
  createAndPerform: (properties = {}) ->
    search = @create properties
    search._perform()

TreeSearch.Base.reopen
  
  # The search will begin with this node
  # @type object
  initialNode: Ember.required()

  # Returns yes when the tested node should be yielded to result
  # Don't forget to call @_super() when providing your implementation.
  # @protected
  # @type Function (Object -> bool)
  shouldAcceptNode: (node) -> yes

  # Search method
  # LeavesOnlySearch traverses only through leaf nodes
  # @type Ember.Mixin (TreeSearch.(BFS | DFS | LeavesOnlySearch))
  method: TreeSearch.BFS

  # If yes, the search will be stopped when a single result
  # has been found
  shouldYieldSingleResult: no

  # If yes, the search skips over the root node 
  shouldIgnoreInitialNode: yes

  # Direction of traversal
  # @type string 'right' | 'left'
  direction: 'right'

  # If the function returns yes, the search halts and returns so far
  # collected result.
  # The current node that will be passed to this method will never be collected
  # in search result.
  # 
  # Don't forget to call @_super() when providing your implementation.
  # @example `shouldAcceptNode: (node) -> @_super() or node.isntRelevant()`
  # 
  # @protected
  # @type Function (Object -> bool)
  shouldStopSearch: (node) -> no

  # Current tree depth relative to initialNode
  # Element at depth == 1 is a direct child of initialNode
  # This parameter is modified by the search algorithm as it iterates 
  # over elements.
  # @readonly
  # @type number
  depth: 0

  # TODO Implement
  # @readonly
  # @type Ember.Error
  error: null

  # Collected search result
  # Automatically returned when calling this.createAndPerform()
  # TODO Enable array observers
  # @type Array
  result: (->
    if @get 'shouldYieldSingleResult' then null else []
  ).property()

  # Called before the search iterates over a node
  # @protected
  # @type Function
  willEnterNode: Ember.K

  # Called after the search iterates over a node
  # @protected
  # @type Function (Object ->)
  didEnterNode: Ember.K

  # Tree cursor tells us how to walk through the tree, from node to node 
  # (how to get node's sibling, child or parent)
  # @protected
  # @type TreeSearch.TreeCursor
  cursorClass: Ember.required()

  # Performs the search and returns result
  # In case of null, you can check the @error property
  # TODO Performance optimizations
  # TODO Should we test every candidate with @shouldStopSearch?
  _perform: ->
    @_pickAlgorithm()
    if @get 'shouldIgnoreInitialNode'
      @set '_cursor', @_getNextCursor()

    while candidate = @_getNextNode()
      shouldStop = @_visitNode candidate
      break if shouldStop
    @get 'result'

  _getNextNode: ->
    @set '_cursor', @_getNextCursor()
    @get '_cursor.node'

  # @returns yes if search should stop
  _visitNode: (candidate) ->
    @willEnterNode candidate
    return yes if @shouldStopSearch candidate
    if @shouldAcceptNode candidate
      @_addToResult candidate
      return yes if @get 'shouldYieldSingleResult'
    @didEnterNode candidate
    return no

  # @returns no if search should stop
  _addToResult: (node) ->
    if @get 'shouldYieldSingleResult'
      @set 'result', node
    else
      (@get 'result').push node

  _pickAlgorithm: ->
    algorithm = @get 'method'
    algorithm.apply this

  # Implemented by the class (mixin) that provides search algorithm
  # @see this.method
  _getNextCursor: null

  # Cursor pointing to current node
  # (dynamic; changes when search is being performed)
  _cursor: (->
    (@get 'cursorClass').create
      node: @get 'initialNode'
  ).property()

  # Alias for @direction with boolean type
  # Yes if left, no if right
  _shouldWalkLeft: (->
    (@get 'direction') is 'left'
  ).property('direction')
