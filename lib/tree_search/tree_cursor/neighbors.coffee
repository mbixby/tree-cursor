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
# * properties should be organized in way that they are only dependent 
#   on properties above them (for sake of clarity). 
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
  
  # @readonly
  # @type TreeCursor | null
  # @example `cursor.get 'parent' # ~> TreeCursor`
  # TODO Make modifiable
  parent: (->
    @_assertExistenceOfParentNodeAccessor()
    @_createParent node: @findParentNode?()
  ).property().meta cursorSpecific: yes 

  # @public
  # @type TreeCursor | null
  firstChild: (->
    @_createFirstChild node: @findFirstChildNode()
  ).property().meta cursorSpecific: yes 

  # @readonly
  # @type TreeCursor | null
  rightSibling: (->
    @_createRightSibling node: @findRightSiblingNode()
  ).property().meta cursorSpecific: yes 

  # @readonly
  # @type TreeCursor | null
  # TODO Add comment to findLeftSiblingNode saying that without it,
  # isolated cursor (volatile / isol.) would be unable to retrieve
  # its left sibling
  leftSibling: (->
    @_createLeftSibling node: @findLeftSiblingNode?()
  ).property().meta cursorSpecific: yes 

  # @readonly
  # @type Array ([TreeCursor])
  rightSiblings: (->
    sibling = @get 'rightSibling'
    _.flatten _.compact [sibling, (sibling?.get 'rightSiblings')]
  ).property('rightSibling', 'rightSibling.rightSiblings'
  ).meta cursorSpecific: yes 

  # @readonly
  # @type Array ([TreeCursor])
  leftSiblings: (->
    sibling = @get 'leftSibling'
    _.flatten _.compact [(sibling?.get 'leftSiblings'), sibling]
  ).property('leftSibling', 'leftSibling.leftSiblings'
  ).meta cursorSpecific: yes 

  # @readonly
  # @type TreeCursor | null
  rightmostSibling: (->
    (@get 'rightSiblings.lastObject') ? null
  ).property('rightSiblings.lastObject'
  ).meta cursorSpecific: yes 

  # @readonly
  # @type TreeCursor | null
  leftmostSibling: (->
    (@get 'leftSiblings.firstObject') ? null
  ).property('leftSiblings.firstObject'
  ).meta cursorSpecific: yes 

  # @readonly
  # @type TreeCursor | null
  lastChild: (->
    firstChild = @get 'firstChild'
    (firstChild?.get 'rightmostSibling') ? firstChild
  ).property('firstChild', 'firstChild.rightmostSibling'
  ).meta cursorSpecific: yes 

  # @readonly
  # @type Array (TreeCursor)
  children: (->
    child = @get 'firstChild'
    _.compact _.flatten [child, child?.get 'rightSiblings']
  ).property('firstChild', 'firstChild.rightSiblings'
  ).meta cursorSpecific: yes 

  # By setting an arbitrary root, you can constrain the tree cursor
  # to a particular subtree. However, this is available only if it's not broken
  # in your particular tree cursor implementation. See @findParent.
  # TODO Every tree subclass must pass tests to make sure it implements 
  # features like this
  # 
  # @readonly
  # @type TreeCursor | null
  root: (->
    (@get 'parent.root') ? this
  ).property('parent.root'
  ).meta cursorSpecific: yes 

  # @readonly
  isLeaf: (->
    not @get 'firstChild'
  ).property('firstChild'
  ).meta cursorSpecific: yes 

  # @readonly
  isRoot: (->
    this is @get 'root'
  ).property('root'
  ).meta cursorSpecific: yes 


  # Private

  # TODO Clarify
  _assertExistenceOfParentNodeAccessor: ->
    Ember.assert "Function findParentNode should be defined. For example if you were to copy any cursor and findParentNode wasn't defined, it would have no way to get back to root. (Because memoized adjacent cursors of the copied cursor would be deleted when copying and it would have to compute them again.)", @findParentNode

  # @type Function (String -> Function)
  # Default behavior for replacing an invalid node is to replace
  # the node with its children.
  # TODO What if the node becomes valid again. Is some information lost?
  # TODO Is memoized parent.children updated?
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

  # TODO Copy information about this cursor (?)
  _createParent: (properties) ->
    @copy @treewideProperties, Em.merge properties,
      # Example of validReplacement: This cursor asked for its parent, but 
      # the parent is invalid and can be replaced. Get parent.parent instead.
      validReplacement: 'parent'

  _createChild: (properties) ->
    @copy @treewideProperties, Em.merge properties, 
      parent: this
      validReplacement: @_validReplacementForNode()

  _createFirstChild: (properties) ->
    @_createChild Em.merge properties, leftSibling: null

  _createSibling: (properties) ->
    @copy (@treewideProperties.concat ['parent']), Em.merge properties, 
      validReplacement: @_validReplacementForNode()

  _createLeftSibling: (properties) ->
    @_createSibling Em.merge properties, rightSibling: this

  _createRightSibling: (properties) ->
    @_createSibling Em.merge properties, leftSibling: this
