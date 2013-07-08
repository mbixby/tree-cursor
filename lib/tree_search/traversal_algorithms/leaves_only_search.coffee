TreeSearch.LeavesOnlySearch = Ember.Mixin.create

  getNextNode: ->
    if @get '_shouldWalkLeft'
      successorOf = (cursor) -> cursor.pred()
    else
      successorOf = (cursor) -> cursor.succ()
    successorOf @get '_treeCursor'
