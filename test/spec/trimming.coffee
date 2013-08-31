describe "Trimming", ->
  tree = Helpers.TreeNode.create ascii: """
           A
         /   \
       B       C
     /  \     / \
    D    E   F    G
  """

  trimming = null
  trimmedTree = null
  cursors = null

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

    trimming = TreeSearch.Trimming.create
      everythingLeftOfBranch: cursors.get 'E'
      everythingRightOfBranch: cursors.get 'C'
    trimmedTree = trimming.perform()

  describe "#trim", ->
    it "should copy and trim the tree", ->
      expect(getNamesOfNodesInTree trimmedTree).to.equal 'A B E C'

    it "should not affect the original tree", ->
      expect(getNamesOfNodesInTree cursors.get 'A').to.equal 'A B D E C F G'

  describe "#_isCursorOutsideBoundaries", ->
    it "should find nodes outside defined boundaries", ->
      original = getAllNodesInTree cursors.get 'A'
      trimmed = _.compact original.map (cursor) -> 
        cursor if trimming._isCursorOutsideBoundaries cursor
      trimmed = trimmed.mapProperty 'name'
      trimmed = trimmed.sort().join ' '
      expect(trimmed).to.equal "D F G"
