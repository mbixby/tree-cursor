require 'tree_search/tree_cursor'
require 'tree_search/traversal_algorithms/*'

# TreeSearch
#
# Iteration over tree nodes with intent to collect and yield nodes that pass
# particular constraints. 
# 
# To use TreeSearch, you have to extend it first with your custom TreeCursor 
# implementation to define how to walk in your tree (from node to node).
# For examples, consult tests or other components that use TreeSearch.
# 
# Note that:
# * you shouldn't reuse the search instance after it's performed
# * consumers of TreeSearch will be exposed to tree nodes, not cursors

TreeSearch.Base = Ember.Object.extend().reopenClass
  
  createAndPerform: (properties = {}) ->
    search = @create properties
    search.perform()

TreeSearch.Base.reopen

  # The search will begin with this node
  # @type Object
  initialNode: Ember.required()
  
  # If the function resolves to true, the tested node will be yielded 
  # to result. By default, every node in the tree is yielded.
  # 
  # Don't forget to call `@_super()` in your implementation.
  # @example `shouldAcceptNode: (node) -> 
  #   (@_super node) and node.shouldYield()`
  # 
  # @public
  # @type Function (Object -> bool)
  shouldAcceptNode: (node) -> yes

  # Search algorithm
  # @public
  # @type TreeSearch.(BFS | DFS)
  method: TreeSearch.BFSWithQueue

  # If yes, the search will be stopped when a single result
  # has been found
  shouldYieldSingleResult: no

  # If yes, the search skips over the root node 
  shouldIgnoreInitialNode: yes

  # Direction of traversal
  # @type string 'right' | 'left'
  direction: 'right'

  # If the function resolves to true, the search halts and returns so far
  # collected result.
  # The current node passed into this function will never be collected 
  # to the search result.
  # 
  # Don't forget to call `@_super()` in your implementation.
  # @example `shouldStopSearch: (node) -> 
  #    (@_super node) or node.shallNotPass()`
  # 
  # @public
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
  # @public
  # @readonly
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

  # Current node 
  # @type Object
  currentNode: undefined

  # Last visited node 
  # @type Object
  previousNode: undefined

  # Tree cursor tells us how to walk through the tree, from node to node 
  # (how to get node's sibling, child or parent)
  # @protected
  # @type TreeSearch.TreeCursor
  cursorClass: Ember.required()

  # Performs the search and returns result
  # In case of null, you can check the @error property
  perform: ->
    if @get 'shouldIgnoreInitialNode'
      @_getNextNode()
    @previousNode = @currentNode
    while @currentNode = @_getNextNode()
      shouldStop = @_visitNode @currentNode
      break if shouldStop
    @get 'result'

  # TODO Publicize search algorithm
  _getNextNode: ->
    args = ['_cursor', 'direction', 'initialCursor', '_searchMeta']
    args = args.map (key) => @get key
    cursor = (@get 'method').getNextCursor args...
    @set '_cursor', cursor
    cursor?.node

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

  # Cursor pointing to the current node
  _cursor: null

  initialCursor: (->
    (@get 'cursorClass').create
      node: @get 'initialNode'
  ).property()

  # Meta variables for search (e.g. queues)
  # TODO Review
  _searchMeta: (-> {} ).property()

  # Alias for @direction with boolean type
  # Yes if left, no if right
  _shouldWalkLeft: (->
    (@get 'direction') is 'left'
  ).property('direction')
