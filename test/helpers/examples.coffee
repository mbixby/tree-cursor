Helpers.Examples = Ember.Object.extend
  
  string: null

  # Splits, maps and joins result.
  # (Results joined to string are more readable)
  # 
  # If a line contains "undefined", it's replaced with undefined.
  # If a line contains "null", it's replaced with null.
  # 
  # transformFunction takes a single split line as an argument
  # If transformFunction returns object with #toString, it is called
  # If transformFunction returns undefined, it's replaced with "undefined".
  # If transformFunction returns null, it's replaced with "null".
  # 
  # @param {Function (Array -> a)} transformFunction
  # @returns {String} joined and mapped results
  map: (transformFunction) ->
    results = (@string.split '\n').map (line) ->
      line = line.split ' '
      line = line.map (string) ->
        if string is 'undefined'
          undefined
        else if string is 'null'
          null
        else 
          string
      transformFunction line

    results = results.map (result) ->
      if result?.toString
        result.toString()
      else if result is undefined
        "undefined"
      else if result is null
        "null"
      else
        result

    results.join ' '



