# TODO Finish implementation
TreeSearch.DFS = Ember.Mixin.create

  # TODO Support for leftward traversal
  # TODO Change @depth property
  _getNextCursor: ->
    queue = @getWithDefault '_queue', [[@get '_cursor', 0]]
    [next, depth] = queue.pop() if queue[0]

    direction = if @get '_shouldWalkLeft' then -1 else 1
    children = (next?.get 'children') ? []
    queue.push [child, depth + 1] for child in children by direction

    @set '_queue', queue
    @set 'depth', depth
    next
