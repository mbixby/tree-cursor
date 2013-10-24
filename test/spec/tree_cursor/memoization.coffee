describe "TreeCursor (memoization)", ->
  tree = """
       A    
     / | ∖  
    B  C  D
   / \
  E   F
  """

  cursors = null

  beforeEach ->
    root = Helpers.AsciiTreeParser.parse tree
    cursors = Ember.Object.createWithMixins
      "A": root.get 'cursor'
      "B": (-> @get 'A.firstChild' ).property()
      "C": (-> @get 'B.rightSibling' ).property()
      "D": (-> @get 'C.rightSibling' ).property()
      "E": (-> @get 'B.firstChild' ).property()
      "F": (-> @get 'C.rightSibling' ).property()

    # Memoize all nodes
    getAllNodesInTree cursors.get 'A'
    
  describe "#resetCursor", ->
    it "should re-run property getters for basic neighbors", ->
      cursor = cursors.get 'B'
      cursor.resetCursor()
      expect(cursor._cachedOrDefinedProperty 'parent').to.not.be.defined
      expect(cursor._cachedOrDefinedProperty 'rightSibling').to.not.be.defined
      expect((cursors.get 'E')._cachedOrDefinedProperty 'parent').to.be.defined

  describe "#resetSubtree", ->
    it "should reset itself recursively all children and their children", ->
      cursor = cursors.get 'B'
      cursor.resetCursor()
      expect(cursor._cachedOrDefinedProperty 'parent').to.not.be.defined
      expect(cursor._cachedOrDefinedProperty 'rightSibling').to.not.be.defined
      expect((cursors.get 'E')._cachedOrDefinedProperty 'parent').to.not.be.defined

  describe "#resetChildren", ->
    it "shoud reset children and their subtrees", ->
      cursor = cursors.get 'B'
      cursor.resetCursor()
      expect(cursor._cachedOrDefinedProperty 'parent').to.be.defined
      expect(cursor._cachedOrDefinedProperty 'rightSibling').to.be.defined
      expect((cursors.get 'E')._cachedOrDefinedProperty 'parent').to.not.be.defined