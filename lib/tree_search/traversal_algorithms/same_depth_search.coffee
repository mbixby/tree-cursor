TreeSearch.SameDepthSearch = Ember.Mixin.create
  
  getNextNode: ->
    next = if @get '_shouldWalkLeft'
      (@get '_treeCursor').leftAtLevel()
    else
      (@get '_treeCursor').rightAtLevel()
