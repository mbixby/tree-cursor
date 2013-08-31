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
# * accessors with direction that can be interpolated ("#{direction}Sibling")
# * extendibility
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
# * recycle cursors from a pool (?)
# * parallelization
# 
# 
# TODO Implementation notes, FRP, Ember, mutability of cursors,
# cursor vs. position, reconstruction of trees from unconnected branches 
# (partial trees), define find*Node methods on nodes
# 
# Functional Pearl: The Zipper, by Gerard Huet
# J#. Functional Programming 7 (5): 549--554 Sepember 1997

TreeSearch.TreeCursor = Ember.Object.extend().reopenClass
  
  # Creating an invalid cursor returns null *or* the nearest valid cursor.
  # For more information about validation, see tree_cursor/validation.coffee
  # @returns {TreeCursor | null}
  create: (parameters = {}) ->
    return null unless parameters.node
    cursor = @_super.apply this, arguments
    cursor._warnAboutMissingMethods()
    cursor.get '_nearestValidCursor'

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

  # By default, two cursors are equal when one of the following is true:
  #   – they're the same object
  #   – they point to the same node *and* node#equals method is defined
  #   – they point to the same instance of node *and* node#equals method 
  #     is not defined
  #     
  # You should provide node#equals method or override this method 
  # in a subclass.
  # 
  # In order to determine whether two cursors point to the same node, you 
  # should declare #equals function on the node prototype. Checking simply 
  # with '===' is sometimes too much or not enough (e.g. when multiple 
  # instances of the same node can exist or when multiple instances can 
  # represent the same node).
  # @public
  equals: (cursor) ->
    return no unless cursor
    (this is cursor) or do =>
      [a, b] = [(@get 'node'), cursor.get 'node']
      isEqualsMethodDefined = ('object' is typeof a) and a.equals?
      if isEqualsMethodDefined
        a.equals b
      else
        a is b

  # @example
  # ```
  #   @copy (@treewideProperties.concat ['parent']),
  #     node: "A"
  # ```
  # Important:
  # Copying will copy the cursor along with the information about the current
  # tree (validators, volatility, specified cached properties, ...). 
  # 
  # @param carryOver {Array} keys of properties to copy over
  # @param other {Object} other properties
  # @public
  copy: (carryOver = @treewideProperties, otherProperties = {}) ->
    carriedOver = @_memoizedPropertiesForKeys carryOver
    specificToCopying = node: @node
    properties = [specificToCopying, carriedOver, otherProperties]
    # Note that order of preference when merging is right to left
    properties = properties.reduce ((a, b) -> Ember.merge a, b), {}
    @constructor.create properties

  # Immutable (!) list of properties shared with cursors in the whole tree.
  # (Unforunately JS doesn't support freezable objects.)
  # @readonly
  treewideProperties: ['root', 'isVolatile', '_validators']

  # TODO Remove
  _init: ->
    @_super.call this, arguments...
    @_translateChildNodesAccessor()
