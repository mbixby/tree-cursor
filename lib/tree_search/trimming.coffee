# TreeSearch.Trimming
# 
# # Trimming by specifying two boundaries
# 
# By specifying two boundaries, a tree can be narrowed down to a subtree:
# 
#            A                       A 
#          /   \        E, C       /   \ 
#        B       C       ~>      B       C      
#      /  \     / \               \     / \
#     D    E   F    G              E   F    G
#     
# Given a left boundary node M and right boundary node N (nodes may equal),
# trimmed tree would consist of every node X when all of the following is true:
# 
# * given B is a branch of M, either X is on branch B or X is a descendant of Y, where Y is a right sibling of a member of branch B
# * given B is a branch of N, either X is on branch B or X is a descendant of Y, where Y is a left sibling of a member of branch B
# 
# Informally, everything left of node M and right of node N is trimmed.
# 
# Note that trimming is performed lazily (see 
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
      validate: (cursor) => @_isCursorInsideBoundaries cursor
      shouldSkipInvalidCursors: yes
      error: "Node has been trimmed away. #{@toString()}"

  # New (copied) root
  _root: (->
    boundary = (@get 'leftBoundary') ? @get 'rightBoundary'
    root = boundary.get 'root'
    root.copy []
  ).property()
  
  # TODO Clean up
  _isCursorInsideBoundaries: (cursor) ->
    (not cursor.isLeftOfCursor @get 'leftBoundary') and
    (not cursor.isRightOfCursor @get 'rightBoundary')

  _extractCursorFrom: (nodeOrCursor) ->
    if nodeOrCursor instanceof TreeSearch.TreeCursor
      nodeOrCursor
    else
      node = nodeOrCursor
      (node.get 'cursor') ? node.cursor
