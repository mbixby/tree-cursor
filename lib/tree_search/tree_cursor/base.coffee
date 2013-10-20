# TreeSearch.TreeCursor
#
# Provides a generic way of traversing trees (getting node's children, 
# siblings, etc.). This essentially allows you to separate node-related data 
# and logic regarding navigation between nodes. 
# 
# # Features
# 
# By implementing at least two methods (e.g. #findParentNode 
# and #findChildrenNodes) you will automatically gain:
# 
# * useful methods for traversal, e.g. #root, #firstChild, #successor, 
#   #leafSuccessor,...
# * memoization of adjacent nodes (for more efficient traversal)
# * breadth-first search, depth-first search and others via TreeSearch class
# * ability to trim trees, prune branches or lazily reject certain nodes
# * ability to work with partial trees (TODO tests)
# * support for volatile trees (trees whose nodes change dynamically) (TODO)
# * nomenclature that follows conventions (popular or from CS literature)
# * common API for tree-like objects which allows for reuse of tree-related 
#   utilities (e.g. Search, Trimming)
# * ability to connect disjoint (partial) trees (see cursor pools)
# * accessors with direction that can be interpolated ("#{direction}Sibling")
# * adaptability; cursors can easily adapted for existing trees with a handful
#   of functions and even *supplement existing* navigation logic (e.g. native 
#   HTML DOM)
# 
# # Usage
# 
# Provide your own tree-specific implemetation by extending this class
# and implementing at least methods #findParentNode and #findChildrenNodes.
# Alternatively you can implement #findParentNode, #findFirstChildNode 
# and #findRightSiblingNode. Implement the rest of #find*Node methods
# for more efficient traversal.
# 
# See examples of usage in component tests or look at DOMUtilities component
# on [Github](TODO link)
# 
# # Antipatterns
# 
# Don't use TreeCursor...
# * when using trees for data storage, not data representation
# * in large trees – there are currently no performance tests
# 
# # Roadmap
# 
# * memoization in volatile trees (explicitly create / remove nodes)
# * better test coverage
# * parallelization
# 
# TODO Implementation notes, FRP, Ember, mutability of cursors,
# cursor vs. position (vs. pointer), reconstruction of trees from unconnected branches 
# (partial trees), define find*Node methods on nodes
# 
# Functional Pearl: The Zipper, by Gerard Huet
# J#. Functional Programming 7 (5): 549--554 Sepember 1997

TreeSearch.TreeCursor = Ember.Object.extend().reopenClass
  
  # Creating an invalid cursor returns null *or* the nearest valid cursor.
  # For more information about validation, see tree_cursor/validation.coffee
  # @returns {TreeCursor | null}
  create: (properties = {}) ->
    return null unless properties.node
    cursor = do =>
      cursor = @_getFromSharedPool properties
      cursor?.setProperties properties
    cursor ?= do => 
      cursor = @_super properties
      @_saveToSharedPool cursor
    cursor.get '_nearestValidCursor'

  _getFromSharedPool: (properties) ->
    properties.cursorPool?.get properties.node

  _saveToSharedPool: (cursor) ->
    (cursor.get 'cursorPool').set cursor.node, cursor
    cursor

TreeSearch.TreeCursor.reopen Ember.Copyable, Ember.Freezable,

  # Current node to which the cursor is pointing
  # @type Object
  # @public
  node: Ember.required()

  # If #isVolatile property is set to true, memoization is completely 
  # turned off. I.e. accessing property like #parent will not cache
  # the result but compute it again.
  # 
  # This is esp. useful when traversing volatile trees, e.g. dynamic HTML.
  # Note that disabling memoization may severely hurt performance.
  # 
  # @see #didChangeTreeVolatility
  # @public
  isVolatile: no

  # @example
  # ```
  #   @copy (@treewideProperties.concat ['parent']), node: "A"
  # ```
  # Important:
  # This will copy the cursor along with the information about its current
  # tree (validators, cursorPool, volatility, cached properties if specified).
  # 
  # @param {Array} carryOver Keys of properties to copy over
  # @param {Object} properties Other properties
  # @public
  copy: (carryOver = @treewideProperties, properties = {}) ->
    carryOverProperties = @_memoizedPropertiesForKeys carryOver.concat ['node']
    @constructor.create Ember.merge carryOverProperties, properties

  # Create a cursor in an existing tree with node from the current cursor.
  # 
  # @param {TreeCursor} tree Existing tree
  # @param {Object} properties
  # @see #copy, #cursorPool, tests for examples
  # @public
  copyIntoTree: (tree, properties = {}) ->
    tree.copy @treewideProperties, Ember.merge properties, node: @node
  
  # By ommitting 'cursorPool' from the list of carried over properties, 
  # this will essentialy create a brand new tree, keeping only validations 
  # and volatility setting.
  # 
  # @param {TreeCursor} constructor
  # @param {Object} properties
  # @see #copy, #cursorPool, tests for examples
  # @public
  copyIntoNewTree: (properties = {}, constructor = @constructor) ->
    constructor.create Ember.merge {
      _validators: (@get '_validators').copy()
      isVolatile: @isVolatile
      node: @node
    }, properties

  concatenatedProperties: ['treewideProperties']

  # Immutable list of properties shared with cursors in the whole tree.
  # TODO Extract into separate object
  # 
  # If you define treewideProperties in your subclass, it will be concatenated
  # with treewideProperties from superclasses.
  # @see concatenatedProperties in Ember
  # @readonly
  treewideProperties: ['cursorPool', 'root', 'isVolatile', '_validators', 'originalTree']

  # Pool of cursors in the tree (map of nodes to cursors) to assert
  # uniqueness of cursors.
  # 
  # Sharing the same pool across multiple individual cursors will indicate
  # that they belong to the same tree. 
  # 
  # Since node equality is used to determine whether cursors belong 
  # to the same tree (i.e. cursors are mapped by node objects), there cannot
  # be multiple objects representing the same node. More robust equality 
  # checks (typical `isEqual` and `hash` method) are currently not supported.
  # Failing to conform to this would affect tree validations and memoization 
  # when traversing tree from disconnected nodes.
  # (Example: Presume two nodes A and B from the same tree which don't know 
  # about each other (no memoized neighbors). When A discovers a neighboring 
  # node, it will check if the node is present in the cursorPool. If the node
  # is equal (Javascript's `===`), to B's node, A will recognize B.
  # 
  # Especially note that:
  # 
  # * no two instances of TreeCursor from the same cursor pool will share
  #   the same node
  # * one node can be shared by two cursors if the cursors belong 
  #   to two different cursor pools. This means that you can create multiple 
  #   different tree representations (abstract trees) from the original tree
  #   just by manipulating cursors (pointers). This is especially useful 
  #   when operating on immutable data or when adding abstract constraints 
  #   (see #copyWithNewValidator).
  # 
  # @type Ember.Map (where keys are nodes; values its cursors)
  # @public
  cursorPool: (->
    Ember.Map.create()
  ).property()

  # TODO Remove
  init: ->
    @_super.call this, arguments...
    @_translateChildNodesAccessor()
