TreeSearch.BFS = Ember.Mixin.create
  
  # TODO Clean up
  _getNextCursor: ->
    direction = @get "direction"
    next = @get "_cursor" unless @get '_current'
    next ?= @get "_current.#{direction}SuccessorAtSameDepth"

    unless next
      firstCursorAtDepth = @getWithDefault "_firstCursorAtCurrentDepth",
        @get "_current"
      next = firstCursorAtDepth.get if direction is "left" then "lastChild" else "firstChild"
      @set "_firstCursorAtCurrentDepth", next
      @incrementProperty "depth"

    @set '_current', next
    next

# BFSWithQueue preloads all children even if they won't be visited 
# while searching
TreeSearch.BFSWithQueue = Ember.Mixin.create
  
  _getNextCursor: ->
    queue = @getWithDefault '_queue', [[@get '_cursor', 0]]
    [next, depth] = queue.shift() if queue[0]

    direction = if @get '_shouldWalkLeft' then -1 else 1
    children = (next?.get 'children') ? []
    queue.push [child, depth + 1] for child in children by direction

    @set '_queue', queue
    @set 'depth', depth
    next
