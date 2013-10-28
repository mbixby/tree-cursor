require 'helpers/collectors'

# Helpers.Node
# Represents an [ordered tree](http://en.wikipedia.org/wiki/Ordered_tree#ordered_tree)
# 
# Typical implementation of node type in Javascript would look like this:
# ```
# Helpers.Node = function TreeNode(){}
# Helpers.Node.prototype.name = null
# Helpers.Node.prototype.childNodes = null # array
# ```
# You should understand:
# 
# * why do we subclass from Ember.Object
# * why do we mix in TreeSearch.Traversable
# * why do we specify #parentNode in addition to #childNodes (you won't
#   find parentNode in mathematical definitions of nodes)
# * why do we need to implement #cursorClass
# * why don't we need to subclass from TreeSearch.ObjectWithSharedPool

Helpers.Node = Ember.Object.extend TreeSearch.Traversable,

  name: undefined
  childNodes: undefined
  parentNode: null

  # By mixing in TreeSearch.Traversable and providing custom cursorClass, 
  # we'll gain all of TreeCursor's perks and features.
  # @see TreeSearch.Traversable
  cursorClass: TreeSearch.TreeCursor.extend
    findChildNodes: (node) -> node.childNodes
    findParentNode: (node) -> node.parentNode