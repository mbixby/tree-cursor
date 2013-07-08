TreeSearch.DFS = Ember.Mixin.create

  # TODO Support for leftward traversal
  getNextNode: ->
    queue = @getWithDefault '_queue', [@get '_treeCursor']
    next = queue.pop()
    queue.push x for x in next.down() by -1
    @set 'queue', queue
    next.node
