# TODO Test unbalanced trees

describe "Base", ->
  tree = TreeNode.create ascii: """
           A
         /   \
       B       C
     /  \     / \
    D    E   F    G
  """

  Search = null

  beforeEach ->
    Search = TreeSearch.Base.extend
      cursorClass: ArrayTreeCursor
      initialNode: tree
      method: TreeSearch.BFS
      shouldIgnoreInitialNode: no

  namesOfNodesIn = (result) ->
    result = result.mapProperty 'name'

  describe "given a search with breadth-first algorithm", ->
    it "should visit nodes in correct order", ->
      result = Search.createAndPerform()
      expect(namesOfNodesIn result).to.have.members "A B C D E F G".w()

    it "should visit nodes in correct order when using a queue", ->
      result = Search.createAndPerform
        method: TreeSearch.BFSWithQueue
      expect(namesOfNodesIn result).to.have.members "A B C D E F G".w()

    it "should work in reverse", ->
      result = Search.createAndPerform
        direction: 'left'
      expect(namesOfNodesIn result).to.have.members "A C F G B E D".w()
      
      result = Search.createAndPerform
        method: TreeSearch.BFSWithQueue
        direction: 'left'
      expect(namesOfNodesIn result).to.have.members "A C F G B E D".w()

  describe "given a search with depth-first algorithm", ->
    beforeEach -> 
      Search.reopen { method: TreeSearch.DFS }

    it "should visit nodes in correct order", ->
      result = Search.createAndPerform()
      expect(namesOfNodesIn result).to.have.members "A B D E C F G".w()

    it "should work in reverse", ->
      result = Search.createAndPerform
        direction: 'left'
      expect(namesOfNodesIn result).to.have.members "A C F G B E D".w()

  describe "given a search with leaves-only algorithm", ->
    beforeEach -> 
      Search.reopen { method: TreeSearch.LeavesOnlySearch }

    it "should visit only leaf nodes", ->
      result = Search.createAndPerform()
      expect(namesOfNodesIn result).to.have.members "D E F G".w()

    it "should work in reverse", ->
      result = Search.createAndPerform
        direction: 'left'
      expect(namesOfNodesIn result).to.have.members "G F E D".w()

  it "should yield single result when told to", ->
    enteredNodes = []
    result = Search.createAndPerform
      shouldYieldSingleResult: yes
      willEnterNode: (node) -> enteredNodes.push node
    expect(result.get "name").to.equal "A"
    expect(namesOfNodesIn enteredNodes).to.not.have.members "B".w()

  it "should ignore initial node when told to", ->
    result = Search.createAndPerform
      shouldIgnoreInitialNode: yes
    expect(namesOfNodesIn result).to.have.members "B C D E F G".w()
