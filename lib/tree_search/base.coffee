# TreeSearch
# TODO Documentation

TreeSearch.reopenClass
  
  createAndPerform: ->
    search = @create.apply this, arguments
    search.perform()

TreeSearch.reopen
  
  # The search will begin with this node
  rootNode: null
  initialNode: Ember.alias 'rootNode'

  # Search method
  # LeavesOnlySearch traverses only through leaf nodes
  # @type Ember.Mixin (TreeSearch.(BFS | DFS | LeavesOnlySearch))
  method: TreeSearch.BFS

  # Returns yes when the tested node should be yielded to result
  # @type Function (Object -> bool)
  shouldAcceptNode: (node) -> yes

  # If yes, the search will be stopped when a single result
  # has been found
  shouldYieldSingleResult: no

  # If yes, the search skips over the root node 
  shouldIgnoreRootNode: yes

  # Direction of traversal, 'left' or 'right'
  # @type string
  direction: 'right'

  # If the function returns yes, the search halts and returns so far
  # collected result
  # @type Function (Object -> bool)
  shouldStopSearch: (node) -> no

  # If the function returns yes, the node will be won't be tested
  # for acceptance. However, it will be passed with @shouldStopSearch
  # @type Function (Object -> bool)
  # Negation of @shouldAcceptNode
  # shouldSkipNode: (node) -> no

  # Performs the search and returns result
  # @returns {Ember.Array (Object) | null} 
  # In case of null, you can check the @error property
  perform: ->
    @_pickAlgorithm()
    result = []
    while candidate = @getNextNode()
      break if @shouldStopSearch candidate
      continue if @shouldSkipNode candidate
      if @shouldAcceptNode candidate
        result.push candidate
        break if @get 'shouldYieldSingleResult'
    @processResult result

  processResult: (result) ->
    if @get 'shouldYieldSingleResult'
      result[0] ? null
    else if Ember.isEmpty result
      null
    else
      result

  # @type DOMUtilities.TreeCursorFactory
  cursorFactoryClass: TreeCursorFactory

  # @type Function (-> Object)
  # Implemented by the class (mixin) that provides search algorithm
  getNextNode: Ember.K()

  _pickAlgorithm: ->
    algorithm = @get 'method'
    algorithm.apply this

  _treeCursor: (->
    (@get 'cursorFactoryClass').createCursor
      initialNode: @get 'rootNode'
  ).property()

  # Alias for @direction with boolean type
  # Yes if left, no if right
  _shouldWalkLeft: (->
    (@get 'direction') is 'left'
  ).property('direction')
