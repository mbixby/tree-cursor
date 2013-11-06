require 'tree_search/tree_cursor/configuration'

# TreeSearch.TreeCursor
# Neighbors
# 
# These properties provide definitions and algorithms for accessing 
# adjacent cursors.
# 
# See also properties in `successors.coffee`, `family.coffee`, 
# `position.coffee` and `aliases.coffee`
# 
# Development notes: 
# * properties should be organized in a way that they are only dependent 
#   on properties above them
# * definitions of properties should be as declarative as possible
# * definitions of properties should suppose that the current cursor 
#   is isolated and doesn't have any information about adjacent cursors –
#   – this means that caching and other optimizations must be abstracted
#   away from the definition
# 
# TODO Comment about impact of findChildNodes vs findFirstChildNode avail.
# (findChildNodes is translated into findFirstChildNode and 
# findRightSiblingNode and not mentioned anymore)
# TODO Modification, dependencies, propagation of changes

TreeSearch.TreeCursor.reopen

  # @public
  # @type TreeCursor | null
  # TODO Implement with #children when circ. dependencies are implemented
  firstChild: (->
    @_createFirstChild node: @findFirstChildNode @node
  ).togglableProperty() 

  # @readonly
  # @type TreeCursor | null
  # TODO Implement with #children when circ. dependencies are implemented
  rightSibling: (->
    @_createRightSibling node: @findRightSiblingNode @node
  ).togglableProperty() 

  # @readonly
  # @type TreeCursor | null
  # TODO Add comment to findLeftSiblingNode saying that without it,
  # isolated cursor (volatile / isol.) would be unable to retrieve
  # its left sibling
  leftSibling: (->
    @_createLeftSibling node: @findLeftSiblingNode? @node
  ).togglableProperty() 

  # @readonly
  # @type TreeCursor | null
  # @example `cursor.get 'parent' # ~> TreeCursor`
  # TODO make dependent on leftSibling.parent (problems with findChildNodes)
  parent: (->
    @_createParent node: @findParentNode? @node
  ).togglableProperty()

  # @readonly
  # @type Array ([TreeCursor])
  rightSiblings: (->
    sibling = @get 'rightSibling'
    _.flatten _.compact [sibling, (sibling?.get 'rightSiblings')]
  ).togglableProperty('rightSibling', 'rightSibling.rightSiblings')

  # @readonly
  # @type Array ([TreeCursor])
  leftSiblings: (->
    sibling = @get 'leftSibling'
    _.flatten _.compact [(sibling?.get 'leftSiblings'), sibling]
  ).togglableProperty('leftSibling', 'leftSibling.leftSiblings')

  # @readonly
  # @type TreeCursor | null
  rightmostSibling: (->
    (@get 'rightSiblings.lastObject') ? null
  ).togglableProperty('rightSiblings.lastObject')

  # @readonly
  # @type TreeCursor | null
  leftmostSibling: (->
    (@get 'leftSiblings.firstObject') ? null
  ).togglableProperty('leftSiblings.firstObject')

  # @readonly
  # @type TreeCursor | null
  lastChild: (->
    firstChild = @get 'firstChild'
    (firstChild?.get 'rightmostSibling') ? firstChild
  ).togglableProperty('firstChild', 'firstChild.rightmostSibling')

  # @readonly
  # @type Array (TreeCursor)
  children: (->
    child = @get 'firstChild'
    _.compact _.flatten [child, child?.get 'rightSiblings']
  ).togglableProperty('firstChild', 'firstChild.rightSiblings')

  # @readonly
  # @type TreeCursor | null
  root: (->
    (@get 'parent.root') ? this
  ).togglableProperty('parent.root')

  # @readonly
  isLeaf: (->
    not @get 'firstChild'
  ).togglableProperty('firstChild')

  # @readonly
  isRoot: (->
    not @get 'parent'
  ).togglableProperty('parent')


  # Private

  # @type Function (String -> Function)
  # Default behavior for replacing an invalid node is to replace
  # the node with its children.
  # TODO What if the node becomes valid again. Is some information lost?
  # TODO Is memoized parent.children updated?
  # TODO Refactor when cursor manipulation is implemented
  _validReplacementForNode: -> 
    ->
      if child = @get "firstChild"
        # Connect @lastChild to @rightSibling
        # TODO Review
        lastChild = (child.get 'rightmostSibling') ? child
        rightSibling = @get 'rightSibling'
        lastChild.set 'rightSibling', rightSibling
        rightSibling.set 'leftSibling', lastChild
        child
      else
        @get "rightSibling"

  _createParent: (properties) ->
    @copy Em.merge properties,
      # Example of validReplacement: This cursor asked for its parent, but 
      # the parent is invalid and can be replaced. Get parent.parent instead.
      validReplacement: 'parent'

  _createFirstChild: (properties) ->
    properties = Em.merge (@getMemoizedProperties ['root']), properties
    @copy Em.merge properties, 
      validReplacement: @_validReplacementForNode()
      parent: this
      leftSibling: null

  _createLeftSibling: (properties) ->
    properties = Em.merge (@getMemoizedProperties ['root', 'parent']), properties
    @copy Em.merge properties, 
      validReplacement: @_validReplacementForNode()
      rightSibling: this

  _createRightSibling: (properties) ->
    properties = Em.merge (@getMemoizedProperties ['root', 'parent']), properties
    @copy Em.merge properties, 
      validReplacement: @_validReplacementForNode()
      leftSibling: this
