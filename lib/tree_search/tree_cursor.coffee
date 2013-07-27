# TreeSearch.TreeCursor
# 
# TODO Docs (functional style, references:
#   See Functional Pearl: The Zipper, by G\'erard Huet
#   J#. Functional Programming 7 (5): 549--554 Sepember 1997
# 
# Provide your own tree-specific implemetation by extending this class
# and implementing at least methods @findParent and @findChildren.
# Alternatively you can implement @findFirstChild and @findRightSibling.

TC = TreeSearch.TreeCursor = Ember.Object.extend().reopenClass
    
  # Fail gracefully when attempting to create cursor without a node
  create: (parameters = {}) ->
    return null unless parameters.node
    @_super.apply this, arguments

  # @private
  memoize: (name) -> 
    ((key, value) -> 
      if value then @_setIfTreeIsNotVolatile key, value
      else  @_getIfTreeIsNotVolatile name
    ).property().volatile()

TreeSearch.TreeCursor.reopen Ember.Copyable, Ember.Freezable,

  # Public properties
  
  # Current node to which the cursor is pointing
  # @type Object
  node: Ember.required()

  # If @isTreeVolatile is set to yes, accessing e.g. @parent will not store
  # the resulting value. Instead, each time you call @parent, it will invoke 
  # @findParent.
  # This is useful when traversing volatile trees, e.g. dynamic HTML.
  # Note that disabling memoization may hurt performance.
  isTreeVolatile: no


  # Public readonly properties
  # Provide basic navigation

  # @readonly
  # @example `cursor.get 'parent' # ~> TreeCursor`
  # @type TreeCursor
  parent: TC.memoize 'parent'

  # @readonly
  # @type Array (TreeCursor)
  children: TC.memoize 'children'

  # @readonly
  # @type TreeCursor
  firstChild: TC.memoize 'firstChild'

  # @readonly
  # @type TreeCursor
  lastChild: TC.memoize 'lastChild'

  # @readonly
  # @type TreeCursor
  rightSibling: TC.memoize 'rightSibling'

  # @readonly
  # @type TreeCursor
  leftSibling: TC.memoize 'leftSibling'

  # @readonly
  # @type TreeCursor
  rightmostSibling: TC.memoize 'rightmostSibling'

  # @readonly
  # @type TreeCursor
  leftmostSibling: TC.memoize 'leftmostSibling'

  # @readonly
  # @type TreeCursor
  successor: TC.memoize 'successor'

  # @readonly
  # @type TreeCursor
  predecessor: TC.memoize 'predecessor'
  
  # @readonly
  # @type TreeCursor
  successorAtSameDepth: TC.memoize 'successorAtSameDepth'

  # @readonly
  # @type TreeCursor
  predecessorAtSameDepth: TC.memoize 'predecessorAtSameDepth'

  # @readonly
  # @type TreeCursor
  leafSuccessor: TC.memoize 'leafSuccessor'
  
  # @readonly
  # @type TreeCursor
  leafPredecessor: TC.memoize 'leafPredecessor'

  # By setting an arbitrary root, you can constrain the tree cursor
  # to a particular subtree. However, this is available only if it's not broken
  # in your particular tree cursor implementation. See @findParent.
  # TODO Every tree subclass must pass tests to make sure it implements 
  # features like this
  # @type TreeCursor
  root: TC.memoize 'root'
    
  # @readonly
  isLeaf: (->
    not @get 'firstChild'
  ).property().volatile()

  # @readonly
  isRoot:  (->
    this is @get 'root'
  ).property().volatile()

  # @alias lastChild
  # Handy when using attributes in bi-directional methods.
  # @example
  # ```
  #   getFirstOrLastChild: (direction) ->
  #     child = cursor.get "firstChildFrom#{direction}"
  # ```
  firstChildFromRight: Ember.computed.alias 'lastChild'

  # @alias firstChild
  firstChildFromLeft: Ember.computed.alias 'firstChild'

  # @alias successor
  rightSuccessor: Ember.computed.alias 'successor'

  # @alias predecessor
  leftSuccessor: Ember.computed.alias 'predecessor'

  # @alias successorAtSameDepth
  rightSuccessorAtSameDepth: Ember.computed.alias 'successorAtSameDepth'

  # @alias predecessorAtSameDepth
  leftSuccessorAtSameDepth: Ember.computed.alias 'predecessorAtSameDepth'

  # @alias leafSuccessor
  rightLeafSuccessor: Ember.computed.alias 'leafSuccessor'

  # @alias leafPredecessor
  leftLeafSuccessor: Ember.computed.alias 'leafPredecessor'


  # Find*Node methods
  # 
  # Implement these methods to provide logic on how to retrieve adjacent nodes.
  # See TreeCursor class in DOMUtilities component to get an example.
  
  # @example
  # ```
  #   findParentNode: -> (jQuery (@get 'node')).children()
  # ```
  # @protected
  # @type Function (-> Array(Object))
  findParentNode: undefined

  # If you provide @findChildNodes, children are automatically memoized,
  # ignoring @isTreeVolatile property. If you don't want to do this,
  # provide at least @findFirstChildNode and @findRightSiblingNode.
  # 
  # @example
  # ```
  #   findChildNodes: -> (@get 'node').childNodes
  # ```
  # @protected
  # @type Function (-> Object)
  findChildNodes: undefined

  # @protected
  # @type Function (-> Object)
  findFirstChildNode: undefined

  # @protected
  # @type Function (-> Object)
  findLastChildNode: undefined

  # @protected
  # @type Function (-> Object)
  findRightSiblingNode: undefined

  # @protected
  # @type Function (-> Object)
  findLeftSiblingNode: undefined
  

  # Find* methods
  # 
  # These provide algorithms for moving the cursor (accessing adjacent nodes) 
  # based on which find*Node methods are available.
  # Usually shouldn't be extended.
  # They shouldn't be accessed
  # TODO Docs

  # @private
  findParent: ->
    if @findParentNode
      @createParent { node: @findParentNode() }

  # @private
  findRoot: ->
    (@get 'parent.root') ? this

  # @private
  findChildren: ->
    if @findChildNodes
      childNodes = @findChildNodes()
      @createChildren (childNodes.map (node) -> { node: node }), childNodes

    else if @findFirstChildNode and @findRightSiblingNode
      (@get 'firstChild')?.findMeAndRightSiblings() ? []

  # @private
  findMeAndRightSiblings: ->
    rightSiblings = @findRightSiblings()
    rightSiblings.unshift this
    rightSiblings

  # @private
  findRightSiblings: ->
    sibling = @get 'rightSibling'
    hisSiblings = sibling?.findRightSiblings() ? []
    hisSiblings.unshift sibling if sibling
    hisSiblings

  # @private
  findFirstChild: ->
    if @findFirstChildNode
      @createFirstChild { node: @findFirstChildNode() }
    else
      @get 'children.firstObject'

  # @private
  findLastChild: ->
    if @findLastChildNode
      @createLastChild { node: @findLastChildNode() }
    else if @findFirstChildNode
      @get 'firstChild.rightmostSibling'
    else
      @get 'children.lastObject'

  # @private
  # Important: this array doesn't need to contains all siblings. It's a stack
  # built lazily over time by @updateMemoizedSiblings. If you call 
  # this.someSiblings.lastObject, it doesn't mean you get the last child of its
  # parent, similarly with firstObject
  someSiblings: (->
    [this]
  ).property()

  # @private
  allSiblings: null

  # @private
  indexInSiblings: 0

  # @private
  # TODO Make more clear
  findRightSibling: ->
    sibling = (@get 'someSiblings').objectAt (@get 'indexInSiblings') + 1
    sibling ?= if @findRightSiblingNode
      sibling = @createRightSibling { node: @findRightSiblingNode() }
      @updateMemoizedSiblings sibling: sibling, direction: 'right'
      sibling

  # @private
  # TODO Make more clear
  findLeftSibling: ->
    sibling = (@get 'someSiblings').objectAt (@get 'indexInSiblings') - 1
    sibling ?= if @findLeftSiblingNode
      sibling = @createLeftSibling { node: @findLeftSiblingNode() }
      @updateMemoizedSiblings sibling: sibling, direction: 'left'
      sibling

  # @private
  # @param opts.sibling {TreeCursor}
  # @param opts.direction 'right' | 'left'
  updateMemoizedSiblings: (opts) ->
    siblings = @get 'someSiblings'
    sibling = opts.sibling

    if sibling
      newSiblings = do ->
        if opts.direction is 'right'
          siblings.push sibling
        else
          siblings.unshift sibling
        siblings

      @set 'someSiblings', newSiblings
      sibling.set 'someSiblings', newSiblings

      if opts.direction is 'left'
        @incrementProperty 'indexInSiblings'
        sibling.incrementProperty 'indexInSiblings'

    else
      # Set allSiblings
      @set "_didMemoize#{opts.direction.capitalize()}mostSibling", yes
      areAllSiblingsMemoized = (@get '_didMemoizeRightmostSibling') and 
        (@get '_didMemoizeLeftmostSibling')
      @set 'allSiblings', siblings if areAllSiblingsMemoized

  # @private
  findRightmostSibling: ->
    (@get 'allSiblings.lastObject') ?
    (@get 'parent.lastChild' if @findLastChildNode) ?
    (@findRightSiblings().get 'lastObject')

  # @private
  findLeftmostSibling: ->
    (@get 'allSiblings.firstObject') ?
    (@get 'parent.firstChild' if @findFirstChildNode)
    # (@findLeftSiblings().get 'firstObject')

  # @see @findPredecessorAndItsDepth() for comments
  # @private
  findSuccessor: ->
    [successor, _] = @findSuccessorAndItsDepth()
    successor

  # @see @findPredecessorAndItsDepth() for comments
  # @private
  findPredecessor: ->
    [predecessor, _] = @findPredecessorAndItsDepth()
    predecessor

  # @see @findPredecessorAndItsDepth() for comments
  # @type Function (number -> [TreeCursor, number])
  # @private
  findSuccessorAndItsDepth: (depth = 0) ->
    [succ, _] = [(@get 'firstChild'), depth + 1]
    [succ, _] = [(@get 'rightSibling'), depth + 0] unless succ
    [succ, _] = (@findUpwardSuccessorAndItsDepth depth) unless succ
    [succ, _]

  # Find predecessor and its depth relative to depth provided
  # as parameter.
  # 
  # In the following example, the search would continue upwards to node 4., 
  # which is our nearest predecessor. Given that our depth is 0, 
  # predecessor's depth relative to ours is -2:
  # ```
  #  (predecessor) 4. /\ 3.
  #                      \ 2.
  #                        \ 1. (this)
  # ```                    
  # 
  # In this example, predecessor's relative depth is 0:
  # ```
  #                  3. /\ 2.
  #  (predecessor) 4. /    \ 1. (this)
  # ```  
  # 
  # Here its relative depth is 1:
  # ```
  #         1. (this)
  #        /|\ 2. (predecessor)
  #      /  |  \ x. (not visited; predecessor's predecessor)
  # ```     
  # 
  # @type Function (number -> [TreeCursor, number])           
  # @private
  findPredecessorAndItsDepth: (depth = 0) ->
    [pred, _] = [(@get 'lastChild'), depth + 1]
    [pred, _] = [(@get 'leftSibling'), depth + 0] unless pred
    [pred, _] = (@findUpwardPredecessorAndItsDepth depth) unless pred
    [pred, _]

  # @type Function (number -> [TreeCursor, number])    
  # @private
  findUpwardSuccessorAndItsDepth: (depth = 0) ->
    succ = @get 'parent.rightSibling'
    [succ, depth] = ((@get 'parent').findUpwardSuccessorAndItsDepth depth) unless succ or not @get 'parent'
    [succ, depth - 1] # Decrementing by one because we asked a parent

  # @type Function (number -> [TreeCursor, number])    
  # @private
  findUpwardPredecessorAndItsDepth: (depth = 0) ->
    pred = @get 'parent.leftSibling'
    [pred, depth] = ((@get 'parent')?.findUpwardPredecessorAndItsDepth depth)unless pred or not @get 'parent'
    [pred, depth - 1] # Decrementing by one because we asked a parent

  # @private
  findSuccessorAtSameDepth: ->
    @findSuccessorAtDepth 0

  # @private
  findPredecessorAtSameDepth: ->
    @findPredecessorAtDepth 0

  # Get next successors until we find one at a specified depth (relative 
  # to ours)
  # @type Function (number -> TreeCursor)
  # @private
  findSuccessorAtDepth: (depth = 0) ->
    # If the successor is at lower depth than this node, we should 
    # walk back up the tree by calling findUpwardSuccessor instead of 
    # findSuccessor. We don't need to visit any lower subtrees.
    [succ, depth] = if depth >= 0 
      rightSibling = @get 'rightSibling'
      ([rightSibling, depth] if rightSibling) ?
      @findUpwardSuccessorAndItsDepth depth
    else
      @findSuccessorAndItsDepth depth
    # Retrieving e.g. [<TreeCursor>, 2] would mean that we found a successor
    # 2 levels below the target depth. 
    
    # Note that using @findSuccessorAndItsDepth with an argument, depth 
    # always stays relative to the original. This way, we only need 
    # to recursively call this function for every next successor until
    # we find one at zero depth.
    return succ if depth is 0
    succ?.findSuccessorAtDepth depth

  # @type Function (number -> TreeCursor)
  # @private
  findPredecessorAtDepth: (depth = 0) ->
    [pred, depth] = if depth >= 0 
      leftSibling = @get 'leftSibling'
      ([leftSibling, depth] if leftSibling) ?
      @findUpwardPredecessorAndItsDepth depth
    else
      @findPredecessorAndItsDepth depth
    return pred if depth is 0
    pred?.findPredecessorAtDepth depth

  # @type Function (number -> TreeCursor)
  # @private
  findLeafSuccessor: (direction = 'right') ->
    succ = @get "#{direction}Successor"
    return unless succ
    successorIsLeaf = not succ.get "firstChild"
    if successorIsLeaf then succ else succ.get "#{direction}LeafSuccessor"

  # @type Function (number -> TreeCursor)
  # @private
  findLeafPredecessor: ->
    @findLeafSuccessor 'left'


  # Create* methods
  # 
  # Create adjancent cursors using find*node methods above.
  # They primarily serve to copy memoized properties to the new cursor.
  # Create* methods usually shouldn't be extended.
  # TODO Docs, extract (?)

  # @private
  createParent: (properties) ->
    return null if this is @_getMemoized 'root'
    @copy ['root'], properties

  # @private
  createChildren: (arrayOfProperties) ->
    siblings = arrayOfProperties.mapProperty 'node'
    for properties, index in arrayOfProperties
      @copy ['root'], Em.merge properties,
        parent: this
        someSiblings: siblings
        allSiblings: siblings
        indexInSiblings: index

  # @private
  createFirstChild: (properties) ->
    @copy ['root'], Em.merge properties,
      parent: this

  # @private
  createLastChild: (properties) ->
    @copy ['root'], Em.merge properties,
      parent: this

  # @private
  createRightSibling: (properties) ->
    @copy 'root parent'.w(), Em.merge properties,
      indexInSiblings: (@get 'indexInSiblings') + 1
      someSiblings: @get 'someSiblings'
      allSiblings: @get 'allSiblings'

  # @private
  createLeftSibling: (properties) ->
    @copy 'root parent'.w(), Em.merge properties,
      indexInSiblings: (@get 'indexInSiblings') - 1
      someSiblings: @get 'someSiblings'
      allSiblings: @get 'allSiblings'

  # Copying and Memoization
  
  # @example
  # ```
  #   @copy 'root'.w(),
  #     indexInSiblings: 0
  # ```
  # @param savedProperties {Array} keys of properties to copy over
  # @param properties {Object}
  copy: (savedProperties = ['root'], properties = {}) ->
    savedProperties = @_saved_properties savedProperties
    @constructor.create (Em.merge savedProperties, properties)
  
  # Get a property. If its value hasn't been saved yet, call its getter
  # (find* function) and save the value. If this cursor has @isTreeVolatile
  # set to true, call getter right away and don't save the value.
  _getIfTreeIsNotVolatile: (name) ->
    getter = @['find' + name.capitalize()]
    if @get 'isTreeVolatile'
      getter.call this
    else
      key = "_saved_#{name}"
      value = @get key
      value ?= do =>
        value = getter.call this
        @set key, value
        value

  # Retrieves memoized property but does not attempt to call its getter
  # if it doesn't exist
  _getMemoized: (key) ->
    @get "_saved_#{key}"

  # Set a specially memoized property (see above)
  _setIfTreeIsNotVolatile: (key, value) ->
    @set "_saved_#{key}", value

  # Construct an object with memoized properties from the current
  # cursor. This can be passed to @create to preserve memoized properties
  # on the next cursor
  _saved_properties: (propertyList = []) ->
    keysAndValues = propertyList.map (name) =>
      key = "_saved_#{name}"
      [key, @get key]
    keysAndValues.reduce ((object, [key, value]) -> 
      object[key] = value
      object
    ), {}

  # Resets cursor with new properties. Can be used instead of this.copy
  # for performance reasons
  # TODO Decouple tree-wide (@isTreeVolatile) from cursor-specific
  # configuration for straightforward removal of cursor-specific residue
  reset: (savedProperties = ['root'], properties = {}) ->
    keys = keysOfPropertiesToDelete = @keysOfMemoizedProperties()
    keys.concat "node".w()
    keys = keys.reject (key) -> savedProperties.contains key
    this[key] = undefined for key in keys
    this[key] = value for key, value of properties

  _keysOfMemoizedProperties: ->
    (key for own key, _ of this when key.match /^_saved_/)
