# TreeSearch.ObjectWithSharedPool
# 
# Extending ObjectWithSharedPool is used to ensure uniqueness
# of initialized objects, i.e. no object with the same unique key
# will be initialized twice. Objects are stored in a shared pool
# in a property on a chosen object. This property has often semantical
# meaning and shouldn't be private.
# Existence of shared pool is not asserted.

TreeSearch.ObjectWithSharedPool = Ember.Object.extend().reopenClass
  
  create: (properties = {}) ->
    if object = @getFromSharedPool properties
      object.setProperties? properties
    else
      object = @_super properties
      @saveToSharedPool object

  getFromSharedPool: (properties) ->
    sharedPool = @sharedPoolForObject properties
    sharedPool?.get @keyForObject properties

  saveToSharedPool: (object) ->
    sharedPool = @sharedPoolForObject object
    sharedPool?.set (@keyForObject object), object
    object

  removeFromSharedPool: (object) ->
    sharedPool = @sharedPoolForObject object
    sharedPool?.remove @keyForObject object
    object

  # @param {object | Ember.Object} properties
  keyForObject: (properties) ->
    Ember.get properties, 'id'

  # Override this method if:
  # * sharedPool is not present in properties for #create or
  # * sharedPool is not present on instances or
  # * sharedPool has an alias
  # @param {object | Ember.Object} properties
  sharedPoolForObject: (properties) ->
    Ember.get properties, 'sharedPool'

TreeSearch.ObjectWithSharedPool.reopen
  
  # Map from keys (see #keyForObject) to objects
  sharedPool: (->
    Ember.Map.create()
  ).property()