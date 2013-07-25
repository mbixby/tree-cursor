TreeSearch.LeavesOnlySearch = Ember.Mixin.create

  _getNextNode: ->
    if @get '_shouldWalkLeft'
      @get '_treeCursor.leafPredecessor'
    else
      @get '_treeCursor.leafSuccessor'
