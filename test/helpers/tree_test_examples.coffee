Helpers.TreeTestExamples = Ember.Object.extend().reopenClass
  
  create: (examples) ->
    @_super { examples: examples }

Helpers.TreeTestExamples.reopen
  
  # e.g. `["node of A is A"]`
  examples: []

  categorizeByMethod: ->
    @examples.reduce ((previous, current) =>
      methodA = previous[0][0]
      methodB = current.w()[0]
      if methodA is methodB
        previous.push current.w()
        previous
      else
        group = [current.w()]
        @groups.push group
        group
    ), [[]]

  # e.g. `[["node of A is A"]]`
  groups: []

  # e.g. `examples.each (method) -> ...`
  each: (callback) ->
    @categorizeByMethod()
    for group in @groups
      methodName = group[0][0]
      group = group.map (example) -> 
        [_, _, node, _, result] = example
        [node, result]
      callback methodName, group
