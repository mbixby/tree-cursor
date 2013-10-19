TreeSearch.BFS = Ember.Object.extend().reopenClass
  
  getNextCursor: (cursor, direction, initialCursor, meta) ->
    next = initialCursor unless cursor
    next ?= cursor.get "#{direction}SuccessorAtSameDepth"
    next ?= do ->
      meta.leftmost ?= initialCursor
      meta.leftmost = meta.leftmost.get "firstChildFrom#{direction.opposite().capitalize()}"

# BFSWithQueue preloads some nodes even if they won't be visited 
# when searching. This may not be desired in dynamic (volatile) trees.
TreeSearch.BFSWithQueue = Ember.Object.extend().reopenClass
  
  getNextCursor: (cursor, direction, initialCursor, meta) ->
    queue = meta._queue ?= [initialCursor]
    next = queue.shift()

    directionStep = if direction is 'left' then -1 else 1
    children = (next?.get 'children') ? []

    for child in children by directionStep
      queue.push child
    next
