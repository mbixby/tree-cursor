# TreeSearch.TreeCursor
# Position

TreeSearch.TreeCursor.reopen

  # @see #determinePositionAgainstCursor
  # @type Function (TreeCursor -> Boolean)
  # @public
  isRightOfCursor: (cursor) -> 
    'right' is @determineHorizontalPositionAgainstCursor cursor

  # @see #determinePositionAgainstCursor
  # @type Function (TreeCursor -> Boolean)
  # @public
  isLeftOfCursor: (cursor) -> 
    'left' is @determineHorizontalPositionAgainstCursor cursor

  # Important:
  # If a cursor is on the same branch, 'top' or 'bottom' is returned.
  # Undefined return value can mean that cursors are the same or that they
  # are not pointing to the same tree.
  # TODO Optimize (memoize branches and ancestors)
  # 
  # @type Function (TreeCursor -> String ('left' | 'right' | 'top' | 
  #   | 'bottom' | undefined))
  # @param {TreeCursor} cursor any cursor in the tree
  # @public
  determinePositionAgainstCursor: (cursor) ->
    position = @determineHorizontalPositionAgainstCursor cursor
    position ?= @determinePositionAgainstMemberOfBranch cursor

  # TODO Optimize (memoize branches and ancestors)
  # @type Function (TreeCursor -> String ('left' | 'right' | undefined))
  # @param {TreeCursor} cursor any cursor in the tree
  # @public
  determineHorizontalPositionAgainstCursor: (cursor) ->
    if (not cursor) or this is cursor
      undefined
    else if ancestors = @findClosestSiblingAncestorsWithCursor cursor
      [a, b] = ancestors
      a?.determinePositionAgainstSibling b

  # @example 
  #   `A.determinePositionAgainstSibling B #=> 'left' if A is amongst 
  #   left Siblings of B`
  # @type Function (TreeCursor -> String ('left' | 'right' | undefined))
  # @param sibling sibling of this cursor
  # @return {'left' | 'right' | undefined} undefined if this is sibling 
  #   or the sibling is not amongst this node's siblings
  # @public
  determinePositionAgainstSibling: (sibling) ->
    return undefined unless sibling
    # Search outwards – optimized for the closest nodes
    nextSiblingPair = ([left, right]) ->
      [(left?.get 'leftSibling'), (right?.get 'rightSibling')]
    
    siblingPair = [this, this]
    while ([left, right] = siblingPair) and (left or right)
      return 'right' if sibling is left
      return 'left' if sibling is right
      siblingPair = (nextSiblingPair siblingPair)
    undefined

  # TODO Review
  # TODO This is a good example of an algorithm that could be optimized based
  # on which memoized properties are available. If the whole branch 
  # is available, getting length in JS arrays is O(1) but if the branch isn't
  # available, we should walk it downwards / upwards
  # 
  # @type Function (TreeCursor -> String ('top' | 'bottom' | undefined))
  # @param cursor
  # @public
  determinePositionAgainstMemberOfBranch: (cursor) ->
    return undefined unless cursor
    [branchA, branchB] = [this, cursor].mapProperty 'branch'

    # Not being the common ancestor would mean they're not on the same branch
    ancestor = @findClosestCommonAncestorWithCursor cursor
    return undefined unless (this is ancestor) or cursor is ancestor

    if branchA.length < branchB.length
      'top'
    else if branchA.length > branchB.length
      'bottom'
    else
      undefined
