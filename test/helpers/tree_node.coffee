# TreeNode
# Represents a fully saturated binary tree

TreeNode = Ember.Object.extend

  # @type {String} ASCII art of the tree
  ascii: null

  # Nodes stored in an array
  tree: (->
    string = (@get 'ascii').replace /[\/\n]/g, ''
    string = string.replace /[ ]*/, ''
    array = string.w()
    matrix = @splitToLevels array
  ).property()

  # Index of the node in @tree
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
