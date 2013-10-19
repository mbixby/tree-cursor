TreeSearch.DFS = Ember.Object.extend().reopenClass

  getNextCursor: (cursor, direction, initialCursor, meta) ->
    next = initialCursor unless cursor
    next ?= cursor.get "#{direction}Successor"

TreeSearch.DFSWithQueue = Ember.Object.extend().reopenClass

  getNextCursor: (cursor, direction, initialCursor, meta) ->
    queue = meta._queue ?= [initialCursor]
    next = queue.pop()

    directionStep = if direction is 'left' then -1 else 1
    children = (next?.get 'children') ? []

    for child in children by directionStep
      queue.push child
    next
