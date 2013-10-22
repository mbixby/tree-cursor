# TODO Tests for 
#   all configurations of cursor
#   status of caches at different points of discovery of adjacent cursors
    
describe "TreeCursor (base)", ->
  tree = """
           A
         /   ∖
       B       C 
     /  ∖     /  ∖
    D    E   F    G
  """

  cursors = null
  Cursor = null

  beforeEach ->
    rootNode = Helpers.AsciiTreeParser.parse tree
    cursors = getListOfCursorsIn rootNode
    Cursor = rootNode.cursorClass

  describe "#create", ->
    it "should retrieve existing cursor from cursor pool", ->
      strayCursor = Cursor.create
        node: cursors.get "C.node"
        cursorPool: cursors.get "C.cursorPool"
      debugger
      expect(strayCursor._cachedOrDefinedProperty 'parent').to.not.be.defined
      expect(strayCursor.get 'parent').to.equal cursors.get "A"

    it "should not retrieve existing cursor from foreign cursor pool", ->
      strayCursor = Cursor.create
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
