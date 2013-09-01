# TreeSearch.Trimming
# 
# # Trimming by specifying two boundaries
# 
# By specifying two boundaries, a tree can be narrowed down to a subtree:
# 
#            A                       A
#          /   \        E, C       /   \
#        B       C       ~>      B       C     
#      /  \     / \               \      
#     D    E   F    G              E   
#     
# Given the tree shown above (left) and nodes E and C, the narrowed down 
# subtree would consist only of nodes A, B, C and E (shown on the right).
# 
# Other methods of trimming are currently not supported.
# Note that trimming is a lazy operation (see 
# TreeCursor#withRejectionCondition).

TreeSearch.Trimming = Ember.Object.extend().reopenClass
  
  # @returns root of the trimmed tree
  trim: (properties) ->
    trimming = @create properties
    trimming.perform()

TreeSearch.Trimming.reopen

  # @type TreeCursor
  leftBoundary: ((_, newValue, cachedValue) ->
    if arguments.length is 1 then cachedValue
    else @_extractCursorFrom newValue
  ).property()

  # @alias leftBoundary
  everythingLeftOfBranch: Ember.computed.alias 'leftBoundary'

  # @type TreeCursor
  rightBoundary: ((_, newValue, cachedValue) ->
    if arguments.length is 1 then cachedValue
    else @_extractCursorFrom newValue
  ).property()

  # @alias rightBoundary
  everythingRightOfBranch: Ember.computed.alias 'rightBoundary'

  # @returns root of the trimmed tree
  # Trimming is lazy thanks to TreeCursor#shouldRejectCursor
  perform: ->
    (@get '_root').addValidation
      validate: (cursor) => not @_isCursorOutsideBoundaries cursor
      shouldSkipInvalidCursors: yes
      error: "Node has been trimmed away. #{@toString()}"

  # New (copied) root
  _root: (->
    boundary = (@get 'leftBoundary') ? @get 'rightBoundary'
    root = boundary.get 'root'
    root.copy []
  ).property()
  
  _isCursorOutsideBoundaries: (cursor) ->
    (cursor.isLeftOrBottomOfCursor @get 'leftBoundary') or
    (cursor.isRightOrBottomOfCursor @get 'rightBoundary')

  _extractCursorFrom: (nodeOrCursor) ->
    if TreeSearch.TreeCursor.detectInstance nodeOrCursor
      nodeOrCursor
    else
      node = nodeOrCursor
      (node.get 'cursor') ? node.cursor
