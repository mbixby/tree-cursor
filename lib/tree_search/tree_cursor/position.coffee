# TreeSearch.TreeCursor
# Position

TreeSearch.TreeCursor.reopen

  # @see #determinePositionAgainstCursor
  # @type Function (TreeCursor -> Boolean)
  # @public
  isRightOrTopOfCursor: (cursor) -> 
    ['right', 'top'].contains @determinePositionAgainstCursor cursor

  # @see #determinePositionAgainstCursor
  # @type Function (TreeCursor -> Boolean)
  # @public
  isLeftOrTopOfCursor: (cursor) -> 
    ['left', 'top'].contains @determinePositionAgainstCursor cursor

  # @type Function (TreeCursor -> String ('left' | 'right' | 'top' | 
  #   | 'bottom' | undefined))
  # @param cursor any cursor in the tree
  # 
  # Important:
  # If a cursor is on the same branch, 'top' or 'bottom' is returned.
  # Undefined return value can mean that cursors are the same or that they
  # are not pointing to the same tree.
  # 
  # TODO Optimize (memoize branches and ancestors)
  # @public
  determinePositionAgainstCursor: (cursor) ->
    if (not cursor) or @equals cursor
      undefined
    else if ancestors = @findClosestSiblingAncestorsWithCursor cursor
      [a, b] = ancestors
      a?.determinePositionAgainstSibling b
    else
      @determinePositionAgainstMemberOfBranch cursor

  # @type Function (TreeCursor -> String ('left' | 'right' | undefined))
  # @param sibling sibling of this cursor
  # Undefined return value means that the sibling is in fact not
  # @public
  determinePositionAgainstSibling: (sibling) ->
    return undefined unless sibling
    for direction in ['left', 'right'] 
      while candidate = (candidate ? this).get "#{direction.opposite()}Sibling"
        return direction if candidate.equals sibling
    undefined

  # @type Function (TreeCursor -> String ('top' | 'bottom' | undefined))
  # @param cursor
  # @public
  # TODO Review
  # TODO This is a good example of an algorithm that could be optimized based
  # on which memoized properties are available. If the whole branch 
  # is available, getting length in JS arrays is O(1) but if the branch isn't
  # available, we should walk it downwards / upwards
  determinePositionAgainstMemberOfBranch: (cursor) ->
    return undefined unless cursor
    [branchA, branchB] = [this, cursor].mapProperty 'branch'

    # Not being the common ancestor would mean they're not on the same branch
    ancestor = @findClosestCommonAncestorWithCursor cursor
    return undefined unless (@equals ancestor) or cursor.equals ancestor

    if branchA.length < branchB.length
      'top'
    else if branchA.length > branchB.length
      'bottom'
    else
      undefined
