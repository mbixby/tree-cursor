require 'tree_search/tree_cursor/validator'

# TreeSearch.TreeCursor
# Validations
# 
# Adding a validation allows us to reject a node – prohibit it from occuring 
# in the tree. Node failing to pass validation becomes 'invalid'.
# 
# Furthermore, given an existing tree, an invalid node can be 'skipped' –
# – meaning that an attempt to #create an invalid node would automatically 
# return a different adjacent node (accessed by #validReplacement).
# 
# In order to avoid infinite recursion, a condition must be
# self-dependent for at least one node of the tree. (TODO Illustrate)
# 
# Conditions are tested on an *unrestricted copy* of the tree.
# This simplifies the validation mechanism and is required to discover every
# valid node in the tree. (To illustrate, if a valid cursor was surrounded 
# by a line of invalid cursors, recursive validation process would not 
# be able to skip the invalid cursors (because they wouldn't be created) 
# to get to other potentially valid cursors adjacent to invalid cursors.)
# 
# Be careful when creating conditions overly dependent on the rest
# of the tree as this can add significant overhead.
# 
# Conditions are checked when #create is called. All conditions are copied 
# to adjacent cursors cloned from this cursor.
# 
# TODO More clear description, note about checking conditions against 
# ghost tree with complete acceptance (false notion), note about propagation
        
TreeSearch.TreeCursor.reopen

  # @see #copyWithNewValidator
  # @param validationParameters {Object} parameters for TreeCursor.Validator
  copyWithNewValidation: (validationParameters, properties, constructor) ->
    validator = TreeSearch.TreeCursor.Validator.create validationParameters
    @copyWithNewValidator validator, properties, constructor

  # Copies this cursors into a new tree that will be checked against 
  # the new validation.
  # 
  # @see copyIntoNewTree
  # @param validator {TreeSearch.TreeCursor.Validator}
  copyWithNewValidator: (validator, properties = {}, constructor) ->
    properties = Ember.merge properties,
      _validators: (@get '_validators').copy().add validator
      originalTree: this
    @copyIntoNewTree properties, constructor

  # In case this cursor is invalid, it can be replaced by a different cursor
  # (or more) specified by this property.
  # Enter property name for adjacent cursor (e.g. 'parent' or 'successor') or
  # a function that retrieves the cursor itself.
  # TODO Clarify that this property is relevant only for #create
  # TODO Clarify result with multiple cursors
  # 
  # @type String | Function (-> TreeCursor) | Function (-> [TreeCursor])
  validReplacement: undefined

  # @type TreeCursor | null
  # Returns null or the nearest valid cursor if the current cursor fails 
  # any validations, returns self if it does not.
  _nearestValidCursor: (->
    failed = @get '_firstFailedValidator'
    if not failed
      this
    else if failed.get 'isTreewideValidation'
      # TODO Invalidate the whole tree
      # (@get 'cursorPool').forEach (_, cursor)
      #   cursor.invalidate()
      null 
    else
      @get '_extractedValidReplacement'
  ).property()

  # Get property or call function from @validAccessor 
  _extractedValidReplacement: (->
    accessor = @get 'validReplacement'
    if 'string' is typeof accessor
      @get accessor
    else
      accessor?.apply this, []
  ).property('validReplacement')

  validations: (->
    _.zipObject (@get '_validators').map (validator) ->
      identifier = validator.identifier ? Ember.guidFor validator
      result = null
      [identifier, result]
  ).property('_validators')

  # @see above
  # @type Ember.Set
  _validators: (->
    Ember.Set.create()
  ).property()

  _firstFailedValidator: (->
    for validator in @get '_validators'
      return validator unless validator.validate @get 'twinFromOriginalTree'
  ).property()

  twinFromOriginalTree: (->
    @copyIntoTree @originalTree
  ).property()

  # Original tree (unrestricted copy without current validators)
  # This property is shared across the tree via #treewideProperties
  originalTree: undefined
