require 'helpers/tree_node'
TreeNode = Helpers.TreeNode

Helpers.ArrayTreeCursor = TreeSearch.TreeCursor.extend
  
  findFirstChildNode: ->
    index = @get 'node.index'
    tree = @get 'node.tree'
    doesChildExist = tree.length > (index[0] + 1)
    unless doesChildExist then null else
      TreeNode.create
        tree: tree
        index: [index[0] + 1, index[1] * 2]

  findRightSiblingNode: ->
    index = @get 'node.index'
    tree = @get 'node.tree'
    isRoot = index[0] is 0
    doesSiblingExist = (not isRoot) and index[1] % 2 is 0 # It's a binary tree
    unless doesSiblingExist then null else
      TreeNode.create
        tree: tree
        index: [index[0], index[1] + 1]

  findParentNode: ->
    debugger unless @get 'node'
    index = @get 'node.index'
    tree = @get 'node.tree'
    doesParentExist = tree[ index[0] - 1 ]
    leftmostSibling = if index[1] % 2 is 0 then index[1] else index[1] - 1
    unless doesParentExist then null else
      TreeNode.create
        tree: tree
        index: [index[0] - 1, leftmostSibling / 2]

  nameBinding: 'node.name'

  toString: -> @get 'name'
