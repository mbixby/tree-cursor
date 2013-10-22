# TreeSearch.ObjectWithSharedPool
# TODO Docs

TreeSearch.ObjectWithSharedPool = Ember.Object.extend().reopenClass
  
  create: (properties = {}) ->
    if object = @getFromSharedPool properties
      object?.setProperties properties
    else
      object = @_super.apply this, arguments
      @saveToSharedPool object

  getFromSharedPool: (properties) ->
    sharedPool = @sharedPoolForObject properties
    sharedPool?.get @keyForObject properties

  saveToSharedPool: (object) ->
    sharedPool = @sharedPoolForObject object
    sharedPool.set (@keyForObject object), object
    object

  # @param {object | Ember.Object} properties
  keyForObject: (properties) ->
    Ember.get properties, 'id'

  # @param {object | Ember.Object} properties
  sharedPoolForObject: (properties) ->
    Ember.get properties, 'sharedPool'

TreeSearch.ObjectWithSharedPool.reopen
  
  # Map from keys (see #keyForObject) to objects
  sharedPool: (->
    Ember.Map.create()
  ).property()