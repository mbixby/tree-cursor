# TogglableComputedProperty
# Bypasses cache if called on object with isVolatile attribute
# set to true
# Exposes 'cursorProperty' on Function for convenient declaration

class TogglableComputedProperty extends Ember.ComputedProperty
  
  constructor: ->
    Ember.ComputedProperty.apply this, arguments

  get: (obj, keyName) ->
    if obj.isVolatile
      @func.call obj, keyName
    else
      Ember.ComputedProperty::get.apply this, arguments

  set: (obj, keyName, value) ->
    if obj.isVolatile or value is undefined
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
