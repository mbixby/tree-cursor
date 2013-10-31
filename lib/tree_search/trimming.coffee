# TreeSearch.Trimming
# 
# Trimming by specifying two boundaries
# 
# By specifying two boundaries, a tree can be narrowed down to a subtree:
# 
#            A                       A 
#          /   \        E, C       /   \ 
#        B       C       ~>      B       C      
#      /  \     / \               \     
#     D    E   F   G               E       
#     
# Given a left boundary node L and right boundary node R (nodes may be equal) 
# and given that:
# 
# * 'branch of node X' is an array of ancestors of X (including X itself)
# * 'left (right) boundary branch' is branch of node L (R)
# 
# Then node X is a 'inside the left (right) boundary' when X is amongst 
# successors (predecessors) of the left (right) boundary or when X is a member
# of the respective boundary branch and when X is not a descendant of any 
# boundary.
# 
# Informally, everything left of node L and right of node R is trimmed.
# 
# Note that trimming is performed lazily (see TreeCursor#copyWithNewValidation)
# Multiple trims are currently not supported (due to the method of memoization 
# of boundaries).
# 
# Development note: As mentioned in TreeCusor documentation, your node lookup
# methods (e.g. `TreeCursor#findParentNode`) should not create multiple objects
# per node. This is needed because when validating a cursor, we need to search
# for its cursor twin in the original (invalid) tree – and we do this 
# by looking for a cursor with an equal node (via TreeCursor#cursorPool). 
# More robust equality checks are currently not supported. 
# See `Helpers.Node` to see how this is handled in practice 
# (`Helpers.Node#nodePool`).

TreeSearch.Trimming = Ember.Object.extend().reopenClass
  
  # @returns root of the trimmed tree
  trim: (properties) ->
    trimming = @create properties
    trimming.perform()

TreeSearch.Trimming.reopen

  # @type TreeCursor
  leftBoundary: null

  # @alias leftBoundary
  everythingLeftOfBranch: Ember.computed.alias 'leftBoundary'

  # @type TreeCursor
  rightBoundary: null

  # @alias rightBoundary
  everythingRightOfBranch: Ember.computed.alias 'rightBoundary'

  # @returns root of the trimmed tree
  # Trimming is lazy thanks to TreeCursor#_validators
  # TODO Don't copy twice
  perform: ->
    @_coalesceBoundariesOnTheSameBranch()
    root = (@get 'leftBoundary.root').copyIntoNewTree {}, @get '_cursorClass'
    root.copyWithNewValidator @get '_validator'

  _validator: (->
    TreeSearch.TreeCursor.Validator.create
      validate: (cursor) => @_isCursorInsideBoundaries cursor
      shouldSkipInvalidCursors: yes
      error: "Node has been trimmed away. #{@toString()}"
  ).property()

  _isCursorInsideBoundaries: (cursor) ->
    (cursor.get '_isInsideOfLeftBoundary') and 
    (cursor.get '_isInsideOfRightBoundary') and
    (not cursor.get  '_isDescendantOfBoundary')

  # We'll extend the cursor class to provide memoized methods for determining 
  # position against trimming boundaries. If this would be done in the base 
  # cursor class, the memoization logic would need to handle lookup by method
  # arguments (i.e. 'boundary' argument for #_isInsideOfLeftBoundary). 
  _cursorClass: (->
    trimming = this
    (@get 'leftBoundary').constructor.extend
      _trimming: trimming

      treewideProperties: ['_trimming', '_leftBoundary', '_rightBoundary']

      _leftBoundary: (->
        (@get '_trimming.leftBoundary').copyIntoTree this
      ).property()

      _rightBoundary: (->
        (@get '_trimming.rightBoundary').copyIntoTree this
      ).property()

      _isInsideOfLeftBoundary: (->
        @_isInsideOfBoundary 'left'
      ).property('leftSuccessor._isInsideOfLeftBoundary')

      _isInsideOfRightBoundary: (->
        @_isInsideOfBoundary 'right'
      ).property('rightSuccessor._isInsideOfRightBoundary')

      _isInsideOfBoundary: (direction) ->
        ((@get "_#{direction}Boundary.branch").contains this) or
        (@get "#{direction}Successor._isInsideOf#{direction.capitalize()}Boundary")

      _isDescendantOfBoundary: (->
        ((@get 'parent.branch')?.contains @get '_leftBoundary') or
        ((@get 'parent.branch')?.contains @get '_rightBoundary')
      ).property('parent.branch')
  ).property()
  
  _coalesceBoundariesOnTheSameBranch: ->
    ancestor = (@get 'leftBoundary').findClosestCommonAncestorWithCursor @get 'rightBoundary'
    if ancestor is @get 'leftBoundary'
      @set 'leftBoundary', @get 'rightBoundary'
    if ancestor is @get 'rightBoundary'
      @set 'rightBoundary', @get 'leftBoundary'