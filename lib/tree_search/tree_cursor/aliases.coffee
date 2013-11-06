alias = TogglableComputedProperty.computed.alias

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
  firstChildFromRight: alias 'lastChild'

  # @alias firstChild
  firstChildFromLeft: alias 'firstChild'

  # @alias successor
  rightSuccessor: alias 'successor'

  # @alias predecessor
  leftSuccessor: alias 'predecessor'

  # @alias successorAtSameDepth
  rightSuccessorAtSameDepth: alias 'successorAtSameDepth'

  # @alias predecessorAtSameDepth
  leftSuccessorAtSameDepth: alias 'predecessorAtSameDepth'

  # @alias leafSuccessor
  rightLeafSuccessor: alias 'leafSuccessor'

  # @alias leafPredecessor
  leftLeafSuccessor: alias 'leafPredecessor'
