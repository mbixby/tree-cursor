TreeSearch.LeavesOnlySearch =

  getNextCursor: (cursor, direction, initialCursor) ->
    if (not cursor) and initialCursor.get 'isLeaf'
      initialCursor
    else
      (cursor ? initialCursor).get "#{direction}LeafSuccessor"
