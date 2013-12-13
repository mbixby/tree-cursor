# TogglableComputedProperty
# 
# Extends Ember.ComputedProperty with additional behavior:
# * cache is be bypassed if the the getter is called from object 
#   with #isVolatile attribute set to true
# * setting to any value at any point always results in proper
#   setup of observers and dependencies (see Ember.ComputedProperty#set)
# * cache is be bypassed if the value is undefined
# 
# TogglableComputedProperty does not support setters.
# Exposes 'togglableProperty' on Function for convenient declaration

class TogglableComputedProperty extends Ember.ComputedProperty
  
  constructor: (func, opts) ->
    # Function with all three arguments is handled differently 
    # in Ember.ComputedProperty#set (setting its value does not result
    # in setting of property value on the object itself but rather saving
    # it into cache)
    wrapper = (keyName, value, cachedValue) ->
      if arguments.length > 1
        value
      else
        cachedValue ? func.apply this, arguments
    Ember.ComputedProperty.call this, wrapper, opts

  get: (obj, keyName) ->
    if obj.isVolatile
      @func.call obj, keyName
    else
      Ember.ComputedProperty::get.apply this, arguments

  set: (obj, keyName, value) ->
    if obj.isVolatile
      value
    else
      Ember.ComputedProperty::set.apply this, arguments

TogglableComputedProperty.computed = (func) ->
  if arguments.length > 1
    args = [].slice.call(arguments, 0, -1)
    func = [].slice.call(arguments, -1)[0]
  cp = new TogglableComputedProperty(func)
  cp.property.apply cp, args if args
  cp

TogglableComputedProperty.computed.alias = (dependentKey) ->
  TogglableComputedProperty.computed dependentKey, (key, value) ->
    if arguments.length > 1
      set this, dependentKey, value
      value
    else
      Ember.get this, dependentKey

Function::togglableProperty = ->
  ret = TogglableComputedProperty.computed this
  ret.property.apply ret, arguments
