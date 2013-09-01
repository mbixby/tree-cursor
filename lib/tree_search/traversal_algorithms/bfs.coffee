TreeSearch.BFS =
  
  getNextCursor: (cursor, direction, initialCursor) ->
    next = initialCursor unless cursor
    next ?= cursor.get "#{direction}SuccessorAtSameDepth"
    next ?= do ->
      leftmost = (cursor.get "#{direction.opposite()}mostSibling") ? cursor
      leftmost?.get "firstChildFrom#{direction.opposite().capitalize()}"

# BFSWithQueue preloads some nodes even if they won't be visited 
# when searching. This is generally not desired in dynamic (volatile) trees.
TreeSearch.BFSWithQueue =
  
  getNextCursor: (cursor, direction, initialCursor, meta) ->
    queue = meta._queue ?= [initialCursor]
    next = queue.shift()

    directionStep = if direction is 'left' then -1 else 1
    children = (next?.get 'children') ? []

    for child in children by directionStep
      queue.push child
    next
