# TODO Tests for 
#   #copy and other public methods
#   volatile trees
#   connecting partial trees, pool of cursors
#   all configurations of cursor
#   memoized adjacent cursor in validReplacement
#   status of caches at different points of discovery of adjacent cursors
#   test isolated cursors, not just cursors derived from root
    
describe "TreeCursor (base)", ->
  tree = Helpers.TreeNode.create ascii: """
           A
         /   \
       B       C
     /  \     /  \
    D    E   F    G
  """

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

  describe "#create", ->
    it "should retrieve existing cursor from cursor pool", ->
      strayCursor = Helpers.ArrayTreeCursor.create 
        node: cursors.get "C.node"
        cursorPool: cursors.get "C.cursorPool"
      expect(strayCursor._cachedOrDefinedProperty 'parent').to.not.be.defined
      expect(strayCursor.get 'parent').to.equal cursors.get "A"

    it "should not retrieve existing cursor from foreign cursor pool", ->
      strayCursor = Helpers.ArrayTreeCursor.create 
        node: cursors.get "C.node"
      expect(strayCursor._cachedOrDefinedProperty 'parent').to.not.be.defined
      expect(strayCursor.get 'parent').to.not.equal cursors.get "A"

  describe "#copy", ->
    it "should duplicate the tree by not carrying over memoized values", ->
      memoizeSomeCursors = do ->
        cursors.get "B"
        cursors.get "C"
      copy = (cursors.get "A").copy []

      # Now the cursors should not be the same objects
      originals = "A B C".w().map (name) -> cursors.get 'name'
      duplicates = [copy, (copy.get 'firstChild'), (copy.get 'lastChild')]
      for [orig, dupe] in _.zip originals, duplicates
        expect(orig).to.not.equal dupe
