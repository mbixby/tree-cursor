# TODO Test unbalanced trees

describe "Base", ->
  tree = Helpers.AsciiTreeParser.parse """
           A
         /   ∖
       B       C 
     /  ∖     /  ∖
    D    E   F    G
  """

  Search = null

  beforeEach ->
    Search = TreeSearch.Base.extend
      initialNode: tree
      method: TreeSearch.BFS

  describe "given a search with breadth-first algorithm", ->
    it "should visit nodes in correct order", ->
      result = Search.createAndPerform()
      expect(getJoinedNamesOfNodes result).to.equal "A B C D E F G"

    it "should visit nodes in correct order when using a queue", ->
      result = Search.createAndPerform
        method: TreeSearch.BFSWithQueue
      expect(getJoinedNamesOfNodes result).to.equal "A B C D E F G"

    it "should work in reverse", ->
      result = Search.createAndPerform
        direction: 'left'
      expect(getJoinedNamesOfNodes result).to.equal "A C B G F E D"
    
    it "should work in reverse using a queue", ->
      result = Search.createAndPerform
        method: TreeSearch.BFSWithQueue
        direction: 'left'
      expect(getJoinedNamesOfNodes result).to.equal "A C B G F E D"

  describe "given a search with depth-first algorithm", ->
    beforeEach -> 
      Search.reopen { method: TreeSearch.DFS }

    it "should visit nodes in correct order", ->
      result = Search.createAndPerform()
      expect(getNamesOfNodes result).to.have.members "A B D E C F G".w()

    it "should work in reverse", ->
      result = Search.createAndPerform
        direction: 'left'
      expect(getNamesOfNodes result).to.have.members "A C F G B E D".w()

  describe "#shouldYieldSingleResult", ->
    it "should force search to yield a single result", ->
      result = Search.createAndPerform
        shouldYieldSingleResult: yes
      expect(result.get "name").to.equal "A"

    it "should force search to halt after finding the first result", ->
      enteredNodes = []
      result = Search.createAndPerform
        shouldYieldSingleResult: yes
        willEnterNode: (node) -> enteredNodes.push node
      expect(getNamesOfNodes enteredNodes).to.not.have.members "B".w()

  describe "#shouldIgnoreInitialNode", ->
    it "should force search to ignore initial node", ->
      result = Search.createAndPerform
        shouldIgnoreInitialNode: yes
      expect(getNamesOfNodes result).to.have.members "B C D E F G".w()
