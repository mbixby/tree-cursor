require 'tree_search/object_with_shared_pool'

# TreeSearch.TreeCursor
# 
# Provides a generic way of traversing trees (getting node's children, 
# siblings, etc.). This essentially allows you to separate node-related data 
# and logic of navigation between nodes.
# 
# # Usage
# 
# Provide your own tree-specific implemetation by extending this class
# and implementing at least methods #findParentNode and #findChildrenNodes.
# Alternatively you can implement #findParentNode, #findFirstChildNode 
# and #findRightSiblingNode. Implement the rest of #find*Node methods
# if you need or already have more efficient way traversal.
# 
# See examples of usage in component tests or look at DOMUtilities component
# on [Github](TODO link)

TreeSearch.TreeCursor = TreeSearch.ObjectWithSharedPool.extend().reopenClass
  
  # Creating an invalid cursor returns null *or* the nearest valid cursor.
  # For more information about validation, see tree_cursor/validation.coffee
  # @returns {TreeCursor | null}
  create: (properties = {}) ->
    return null unless properties.node
    cursor = @_super properties
    cursor.get '_nearestValidCursor'

  # @overrides TreeSearch.ObjectWithSharedPool#keyForObject
  keyForObject: (properties) -> 
    properties.node

  # @overrides TreeSearch.ObjectWithSharedPool#sharedPoolForObject
  sharedPoolForObject: (properties) ->
    Ember.get properties, 'cursorPool'

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
  # Note that disabling memoization may hurt performance.
  # Volatility currently only applies for properties of TreeSearch.TreeCursor 
  # and not properties of its subclasses.
  # 
  # @see #didChangeTreeVolatility
  # @public
  isVolatile: no

  # Copies a cursor keeping only node and properties from #treewideProperties
  # 
  # @param {Object} properties
  # @public
  copy: (properties = {}) ->
    propagatedProperties = @getProperties @treewideProperties.concat ['node']
    @constructor.create Ember.merge propagatedProperties, properties

  # Creates a cursor in an existing tree with node from the current cursor
  # 
  # @param {TreeCursor} tree Existing tree
  # @param {Object} properties
  # @see #copy, #cursorPool, tests for examples
  # @public
  copyIntoTree: (tree, properties = {}) ->
    tree.copy Ember.merge properties, node: @node
  
  # Copies the cursor into a new tree, keeping only node, validators 
  # and volatility setting
  # 
  # @param {TreeCursor} constructor
  # @param {Object} properties
  # @see #copy, #cursorPool, tests for examples
  # @public
  copyIntoNewTree: (properties = {}, constructor = @constructor) ->
    constructor.create Ember.merge {
      node: @node
      _validators: (@get '_validators').copy()
      isVolatile: @isVolatile
    }, properties

  # @see Ember.Object#concatenatedProperties
  concatenatedProperties: ['treewideProperties']

  # Immutable list of properties shared with cursors in the whole tree.
  # TODO Extract into separate object
  # 
  # If you define treewideProperties in your subclass, it will be concatenated
  # with treewideProperties from superclasses.
  # @see concatenatedProperties in Ember
  # @readonly
  treewideProperties: ['cursorPool', 'isVolatile', '_validators', 'originalTree']

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
  # TODO Clarify this comment (start with reasons for cursorPool, include case
  # when you don't need to know about this – tree walked from root)
  # 
  # @type Ember.Map (where keys are nodes; values its cursors)
  # @public
  cursorPool: Ember.computed.alias 'sharedPool'

  # TODO Remove
  init: ->
    @_super.call this, arguments...
    @_translateChildNodesAccessor()

  # Name of the cursor
  # @type string
  name: Ember.computed.oneWay 'node.name'

  toString: ->
    (@get 'name') ? @_super()
