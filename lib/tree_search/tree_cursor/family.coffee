# TreeSearch.TreeCursor
# Family
# 
# Notable properties:
# * `depth`
# * `branch`
#   
# Definitions of properties below should be implied by their declaration
# (implementation)

TreeSearch.TreeCursor.reopen

  # List of this cursor and its parent cursors up to root
  # @readonly
  # @type TreeCursor | null
  branch: (->
    _.flatten _.compact [this, (@get 'parent.branch')]
  ).property('parent.branch').meta cursorSpecific: yes
  
  # Distance from the root (root being at depth 0)
  # @type Number (0 <= x <= Infinity)
  # @readonly
  depth: (->
    (@get 'branch.length') - 1
  ).property('branch').meta cursorSpecific: yes

  # @type Function (TreeCursor -> TreeCursor | undefined)
  # Undefined return value can mean the cursors are not in the same tree.
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
  # Undefined return value can mean the cursors are not in the same tree.
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
  # @type Function (TreeCursor -> [TreeCursor, TreeCursor] | undefined)
  # Undefined return value can mean the cursors are not in the same tree.
  # @public
  findClosestSiblingAncestorsWithCursor: (cursor) -> 
    [a, b] = [this, cursor]
    ancestor = a.findClosestCommonAncestorWithCursor b
    [a, b] = siblings = for cursor in [a, b]
      ancestor?.findChildBelongingToBranch cursor.get 'branch'
    siblings if a and b
