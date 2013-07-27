TreeSearch.LeavesOnlySearch = Ember.Mixin.create

  _getNextCursor: ->
    direction = @get 'direction'
    next = unless @get '_current'
      (@get '_cursor' if @get '_cursor.isLeaf') ?
      @get "_cursor.#{direction}LeafSuccessor"
    else
      @get "_current.#{direction}LeafSuccessor"

    @set '_current', next
    next
