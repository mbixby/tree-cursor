TreeSearch.BFS = Ember.Mixin.create
  
  getNextNode: ->
    next = if @get '_shouldWalkLeft'
      (@get '_treeCursor').leftAtLevel()
    else
      (@get '_treeCursor').rightAtLevel()
    next ?= @set '_firstNodeAtCurrentLevel', 
      (@getWithDefault '_firstNodeAtCurrentLevel', @get '_treeCursor').down()
    next.node


TreeSearch.BFSWithQueue = Ember.Mixin.create

  # TODO Support for leftward traversal
  getNextNode: ->
    queue = @getWithDefault '_queue', [@get '_treeCursor']
    next = queue.shift()
    queue.push x for x in next.down()
    @set 'queue', queue
    next.node
