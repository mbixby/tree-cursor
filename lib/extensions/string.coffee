if Ember.EXTEND_PROTOTYPES or Ember.EXTEND_PROTOTYPES.String

  # TODO Docs
  String.prototype.stripPrefix = (prefix) ->
    regex = new RegExp "^" + prefix
    @replace regex, ''

  # TODO Docs
  String.prototype.contains = (searchedString) ->
    regex = new RegExp searchedString
    @match regex

  # TODO Docs
  String.Inflector ?= {}

  # TODO Docs
  String.Inflector.opposites =
    start: "end"
    end: "start"
    left: "right"
    right: "left"
    true: "false"
    false: "true"
    yes: "no"
    no: "yes"

  # TODO Docs
  String.prototype.opposite = ->
    String.Inflector.opposites[this]
