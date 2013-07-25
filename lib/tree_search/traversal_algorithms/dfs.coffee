# TODO Finish implementation
TreeSearch.DFS = Ember.Mixin.create

  # TODO Support for leftward traversal
  # TODO Change @depth property
  _getNextNode: ->
    queue = @getWithDefault '_queue', [@get '_treeCursor']
    next = queue.pop()
    queue.push x for x in next.children() by -1
    @set '_queue', queue
    next.node
