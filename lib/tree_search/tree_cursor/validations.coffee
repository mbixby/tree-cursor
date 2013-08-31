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
# Conditions are tested on an *unrestricted copy* of the tree in order
# to simplify the rejection mechanism and prevent unnecessary infinite
# recursive loops (i.e. in conditions that depend on the rest of the tree).
# (TODO Temporary)
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

  # @see #addValidator
  # @param validationParameters {Object} parameters for TreeCursor.Validator
  addValidation: (parameters) ->
    @addValidator TreeSearch.TreeCursor.Validator.create parameters

  # @param validator {TreeSearch.TreeCursor.Validator}
  # @returns modified self
  addValidator: (validator) ->
    (@get '_validators').push validator
    this

  # In case this cursor is invalid, it can be replaced by a different cursor
  # specified by this property.
  # Enter property name for adjacent cursor (e.g. 'parent' or 'successor') or
  # a function that retrieves the cursor itself.
  # TODO Clarify that this property is relevant only as an argument for #create
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
    else if failed.get 'shouldSkipInvalidCursors'
      @get '_extractedValidReplacement'
    else
      null
  ).property()

  # Get property or call function from @validAccessor 
  _extractedValidReplacement: (->
    accessor = @get 'validReplacement'
    if 'string' is typeof accessor
      @get accessor
    else
      accessor?.apply this, []
  ).property('validReplacement')

  # @see above
  _validators: (->
    [@_validateExistenceOfNode]
  ).property()

  # Example validator
  # Invalidates cursor without a node
  # @see above
  _validateExistenceOfNode: TreeSearch.TreeCursor.Validator.create
    # TODO 0 and "" don't pass
    validate: (cursor) -> (cursor.node isnt undefined) and cursor.node isnt null
    shouldSkipInvalidCursors: no
    error: "Node does not exist"

  # TODO Complete the partial tree until it can be validated, only then 
  # validate
  # @returns {Array} failed conditions
  _firstFailedValidator: (->
    for validator in @get '_validators'
      return validator unless validator.validate this
  ).property()

  _warnAboutMissingMethods: ->
    return if @constructor._didWarnBefore # Don't nag
    node = @get 'node'
    doesNodeDefineEqualsMethod = ('object' isnt typeof node) or
      (('object' is typeof node) and node?.equals?)
    Ember.warn "You have not defined #equals method on the node prototype. Please see documentation for TreeCursor#equals for more information. – #{@constructor.toString()}", doesNodeDefineEqualsMethod
    @constructor._didWarnBefore = yes unless doesNodeDefineEqualsMethod
