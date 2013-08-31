# TreeSearch.TreeCursor
# Aliases
# 
# Useful when using attributes in bi-directional methods.
# @example
# ```
#   getFirstOrLastChild: (direction) ->
#     child = cursor.get "firstChildFrom#{direction}"
# ```

TreeSearch.TreeCursor.reopen

  # @alias lastChild
  firstChildFromRight: Ember.computed.alias 'lastChild'

  # @alias firstChild
  firstChildFromLeft: Ember.computed.alias 'firstChild'

  # @alias successor
  rightSuccessor: Ember.computed.alias 'successor'

  # @alias predecessor
  leftSuccessor: Ember.computed.alias 'predecessor'

  # @alias successorAtSameDepth
  rightSuccessorAtSameDepth: Ember.computed.alias 'successorAtSameDepth'

  # @alias predecessorAtSameDepth
  leftSuccessorAtSameDepth: Ember.computed.alias 'predecessorAtSameDepth'

  # @alias leafSuccessor
  rightLeafSuccessor: Ember.computed.alias 'leafSuccessor'

  # @alias leafPredecessor
  leftLeafSuccessor: Ember.computed.alias 'leafPredecessor'
