TreeSearch.BFS = Ember.Mixin.create
  
  # TODO Clean up
  _getNextCursor: ->
    direction = @get "direction"
    next = @get "_cursor" unless @get '_current'
    next ?= @get "_current.#{direction}SuccessorAtSameDepth"

    # Move one level down
    unless next
      # Determine first non-leaf node at current depth (let's call 
      # it firstCursorAtDepth or "_carriageReturn") and continue
      # at its first child
      oppositeDirection = if direction is "left" then "Right" else "Left"
      next = @get "_carriageReturn.firstChildFrom#{oppositeDirection}"
      @set "_carriageReturn", null
      @incrementProperty "depth"

    unless @get "_carriageReturn"
      @set "_carriageReturn", if next?.get 'isLeaf' then null else next

    @set '_current', next
    next

# BFSWithQueue preloads some nodes even if they are not visited 
# when searching. This is generally not desired in dynamic trees
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
