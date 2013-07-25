TreeSearch.LeavesOnlySearch = Ember.Mixin.create

  _getNextCursor: ->
    direction = @get 'direction'
    @get "_treeCursor.#{direction}LeafSuccessor"
