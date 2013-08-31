# TreeSearch.TreeCursor.Validator
# Ispired by 

TreeSearch.TreeCursor.Validator = Ember.Object.extend
  
  # @type String
  error: undefined

  # Returns false if the cursor is prohibited from occurring in the tree
  # @param Function (TreeCursor -> Boolean)
  validate: undefined

  # @see TreeCursor#skippableToCursor property
  shouldSkipInvalidCursors: no
