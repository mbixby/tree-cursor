# TreeNode
# Represents perfect (fully saturated) binary tree

Helpers.TreeNode = Ember.Object.extend().reopenClass
  
  create: (properties = {}) ->
    node = @_getFromSharedPool properties
    node ?= do => 
      node = @_super properties
      @_saveToSharedPool node

  _getFromSharedPool: (properties) ->
    properties.nodePool?.get @_serializeIndex properties.index

  _saveToSharedPool: (node) ->
    (node.get 'nodePool').set (@_serializeIndex node.index), node
    node

  _serializeIndex: (index) ->
    # It's just for testing...
    "#{index[0]}-#{index[1]}"

Helpers.TreeNode = Helpers.TreeNode.reopen TreeSearch.Traversable,
  
  # @type {String} ASCII art of the tree
  ascii: null

  # Tree stored in a matrix
  tree: (->
    string = (@get 'ascii').replace /[\/\n]/g, ''
    string = string.replace /[ ]*/, ''
    array = string.w()
    matrix = @splitToLevels array
  ).property()

  # Tuple [level, positionInLevel] denoting position 
  # of the node in this.tree
  index: [0, 0]

  # Number of levels
  depthBinding: 'tree.length'
  
  toString: ->
    @get 'name'

  name: (->
    index = @get 'index'
    (@get 'tree')[ index[0] ][ index[1] ]
  ).property()

  # @param {Array} tree
  splitToLevels: (array) ->
    numberOfLevels = (Math.log (array.length + 1)) / Math.LN2
    numberOfNodesAtLevel = (Math.pow 2, x for x in [0...numberOfLevels])
    numberOfNodesAtLevel.map (count) ->
      array.shift() while count--

  cursorClass: (->
    Helpers.ArrayTreeCursor
  ).property()

  # Object pool to assert uniqueness of nodes
  nodePool: (->
    Ember.Map.create()
  ).property()

  copy: (properties) -> 
    @constructor.create Ember.merge properties,
      tree: @get 'tree'
      nodePool: @get 'nodePool'