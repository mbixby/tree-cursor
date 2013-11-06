# TreeSearch.TreeCursor
# Family
# 
# Notable properties:
# * `depth`
# * `branch`
# 
# Definitions roughly from Cormen et al.: Introduction to Algorithms

TreeSearch.TreeCursor.reopen

  # List of this cursor and its parent cursors up to root
  # @type TreeCursor | null
  # @readonly
  branch: (->
    _.flatten _.compact [this, (@get 'parent.branch')]
  ).togglableProperty('parent.branch')
  
  # Distance from the root (root being at depth 0)
  # @type Number (0 <= x <= Infinity)
  # @readonly
  depth: (->
    (@get 'branch.length') - 1
  ).togglableProperty('branch')

  # Number of edges on the longest downward simple path to a leaf
  # @type Number (0 <= x <= Infinity)
  # @readonly
  height: (->
    if @get 'isLeaf'
      0
    else
      1 + _.max (@get 'children').mapProperty 'height'
  ).togglableProperty('isLeaf', 'children.@each.height')

  # @type Function (TreeCursor -> TreeCursor | undefined)
  # @return undefined if the cursors are not in the same tree
  # @public
  findClosestCommonAncestorWithCursor: (cursor) ->
    branches = [this, cursor].map (c) -> 
      (c.get 'branch').slice().reverse()
    branches = _.zip branches...

    # Trace the lineage from root
    _.head _.reduce branches, (([commonAncestor, shouldStop], [ancestorA, ancestorB]) ->
      if (not shouldStop) and ancestorA is ancestorB
        [ancestorA, no]
      # Stop reducing when we hit the result
      else
        [commonAncestor, shouldStop = yes]
      ), [null, no]

  # Returns a child that belongs to a given branch
  # @type Function (Array ([TreeCursor]) -> TreeCursor | undefined)
  # @return undefined if the cursors are not in the same tree
  # @public
  findChildBelongingToBranch: (branch) ->
    for candidate in branch
      return candidate if this is candidate.get 'parent'
    undefined

  # Sibling ancestors of nodes A, B are nodes C, D if and only if:
  #   – C and D are ancestors of A and B, respectively
  #   – C and D are siblings
  #   – (therefore C, D are children of the closest common ancestor of A and B)
  # 
  # Note that A, B can equal C, D respectively and that C can equal D.
  # 
  # @type Function (TreeCursor -> [TreeCursor, TreeCursor] | undefined)
  # @return undefined if the cursors are not in the same tree
  # @public
  findClosestSiblingAncestorsWithCursor: (cursor) -> 
    [a, b] = [this, cursor]
    ancestor = a.findClosestCommonAncestorWithCursor b
    [a, b] = siblings = for cursor in [a, b]
      ancestor?.findChildBelongingToBranch cursor.get 'branch'
    siblings if a and b
