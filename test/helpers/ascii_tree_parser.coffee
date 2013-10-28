# Helpers.AsciiTreeParser
# Converts ASCII art trees into Helper.TreeNode
# 
# Note that you need to use different character for backslash – '∖' 
# instead of '\'

Helpers.AsciiTreeParser = Ember.Object.extend().reopenClass
  
  # @returns {Helpers.Node} root 
  parse: (ascii) ->
    return unless ascii
    lines = ascii.split '\n'
    lines.unshift '/'
    lines = @convertLinesIntoArrays lines
    levels = for [edges, nodes] in lines.chunk 2
      nodes = @createNodes nodes
      @groupNodes nodes, edges
    @linkChildren levels
    root = levels[level = 0][group = 0][node = 0]

  # " A B " ~> ['A', 'B']
  convertLinesIntoArrays: (lines) ->
    lines.map (string) ->
      string = string.replace /\s+/g, ' '
      string = string.replace /^\s+|\s+$/g, ''
      string.split " "

  # ['A', 'B'] ~> [Node, Node]
  createNodes: (nodes) ->
    nodePool = Ember.Map.create()
    nodes.map (nodeName) ->
      Helpers.Node.create
        name: nodeName
        nodePool: nodePool

  # Translate: ```
  #   / / | \ / \ \
  #   A B C D E F G
  # ```
  # into: ```
  #   [[A], [B C D], [E F G]]
  # ```
  # In "/ | | | / | \ / \ \", each "/" character is an 'edge' and means 
  # that the node under it is a start of some new children (whose parent
  # is above the edge).
  groupNodes: (nodes, edges) ->
    (_.zip edges, nodes).reduce ((groups, [edge, node]) ->
      if edge is '/' 
        groups.push [node]
      else
        groups[groups.length-1].push node
      groups
    ), []

  linkChildren: (levels) ->
    for level, depth in levels
      nodeIndex = 0
      for group in level
        for node in group
          nextLevel = levels[depth + 1]
          children = nextLevel?[nodeIndex] ? []
          node.childNodes = children
          child.parentNode = node for child in children
          nodeIndex++
