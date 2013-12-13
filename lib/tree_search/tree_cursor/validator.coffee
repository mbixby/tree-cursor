# TreeSearch.TreeCursor.Validator
# Ispired by 

TreeSearch.TreeCursor.Validator = Ember.Object.extend
  
  # @type String
  error: undefined

  # Returns false if the cursor is prohibited from occurring in the tree
  # @param Function (TreeCursor -> Boolean)
  validate: undefined

  # By default, any invalid node is skipped (replaced by its children).
  # If isTreewideValidation is set to true, the tree is invalid
  # when any one of its nodes (cursors) is invalid.
  # isTreewideValidation: no
