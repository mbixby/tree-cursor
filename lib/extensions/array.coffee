if Ember.EXTEND_PROTOTYPES or Ember.EXTEND_PROTOTYPES.Array

  # Splits array into chunks of specified length
  # ```
  # [1, 2, 3, 4].chunk 2   #=> [[1, 2], [3, 4]]
  # ```
  # @param n chunk size
  Array::chunk = (n) ->
    for item, i in this by n
      this[i+x] for x in [0...n]