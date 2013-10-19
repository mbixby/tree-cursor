_Debug = 
  # How much time is spent in a given function
  # Requires browser with window.performance
  # @example `_Debug.bench => doStuff()`
  # @returns result of fn
  bench: (fnOrLabel, fn) ->
    label = if fn then fnOrLabel else 'bench'
    fn = fn ? fnOrLabel
    timer = performance.now()
    ret = fn()
    delta = performance.now() - timer
    window[label] ?= 0
    window[label] += delta
    # window[label + "_count"] ?= 0
    # window[label + "_count"] += 1
    # window[label + "_points"] ?= []
    # window[label + "_points"].push delta if delta > 2
    ret

setTimeout (->
  console.log window.bench if window.bench
), 1000