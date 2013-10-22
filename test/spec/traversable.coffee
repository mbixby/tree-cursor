describe "Traversable", ->
  tree = Helpers.AsciiTreeParser.parse """
           A
         /   \
       B       C
     /  \     / \
    D    E   F    G
  """

  it "should alias properties from cursor", ->
    node = tree.get 'node.firstChild'
    expect(node).to.be.an.instanceof Helpers.TreeNode

  it "should alias properties with type of array", ->
    rootNode = tree.get 'node'
    nodes = rootNode.get 'children'
    expect(nodes[0]).to.be.an.instanceof Helpers.TreeNode

  it "should alias properties with type that's not TreeCursor", ->
    expect(tree.get 'isVolatile').to.equal no

