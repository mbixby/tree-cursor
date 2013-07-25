TreeSearch.BFS = Ember.Mixin.create
  
  _getNextNode: ->
    successor = if @get '_shouldWalkLeft' then 'predecessor' else 'successor'
    next = @get "_treeCursor.#{successor}AtSameDepth"
    unless next
      next = @get '_treeCursor.firstChild'
      @incrementProperty depth
    next

TreeSearch.BFSWithQueue = Ember.Mixin.create

  _getNextNode: ->
    queue = @getWithDefault '_queue', [[@get '_treeCursor', 0]]
    [next, depth] = queue.shift()
    direction = if @get '_shouldWalkLeft' then -1 else 1
    queue.push [x, depth + 1] for x in next.get 'children' by direction
    @set '_queue', queue
    @set 'depth', depth
    next
