describe "Trimming", ->
  tree = Helpers.TreeNode.create ascii: """
           A
         /   \
       B       C
     /  \     / \
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
    cursors = (Ember.Object.extend
      "A": (-> Helpers.ArrayTreeCursor.create node: tree ).property()
      "B": (-> @get 'A.firstChild' ).property()
      "C": (-> @get 'A.lastChild' ).property()
      "D": (-> @get 'B.firstChild' ).property()
      "E": (-> @get 'B.lastChild' ).property()
      "F": (-> @get 'C.firstChild' ).property()
      "G": (-> @get 'C.lastChild' ).property()
    ).create()

  describe "#trim", ->
    it "should copy and trim the tree", ->
      trimmedTree = trimOutsidesOf 'E', 'F'
      expect(getNamesOfNodesInTree trimmedTree).to.equal 'A B E C F'

    it "should not affect the original tree", ->
      trimOutsidesOf 'E', 'F'
      expect(getNamesOfNodesInTree cursors.get 'A').to.equal 'A B D E C F G'
