describe "Trimming", ->
  tree = """
           A
         /   ∖
       B       C 
     /  ∖     /  ∖
    D    E   F    G
  """

  trimming = null
  cursors = null

  trimOutsidesOf = (leftBoundary, rightBoundary) ->
    trimming = TreeSearch.Trimming.create
      everythingLeftOfBranch: cursors.get leftBoundary
      everythingRightOfBranch: cursors.get rightBoundary
    trimming.perform()

  beforeEach ->
    cursors = getListOfCursorsIn Helpers.AsciiTreeParser.parse tree

  describe "#trim", ->
    it "should copy and trim the tree", ->
      trimmedTree = trimOutsidesOf 'E', 'F'
      expect(getNamesOfNodesInTree trimmedTree).to.equal 'A B E C F'

    it "should accept the same cursors", ->
      trimmedTree = trimOutsidesOf 'E', 'E'
      expect(getNamesOfNodesInTree trimmedTree).to.equal 'A B E'

    it "should accept cursors on the same branch", ->
      trimmedTree = trimOutsidesOf 'B', 'E'
      expect(getNamesOfNodesInTree trimmedTree).to.equal 'A B E'

    it "should accept boundaries that are not leaves", ->
      trimmedTree = trimOutsidesOf 'B', 'C'
      expect(getNamesOfNodesInTree trimmedTree).to.equal 'A B C'

    it "should not affect the original tree", ->
      trimOutsidesOf 'E', 'F'
      expect(getNamesOfNodesInTree cursors.get 'A').to.equal 'A B D E C F G'