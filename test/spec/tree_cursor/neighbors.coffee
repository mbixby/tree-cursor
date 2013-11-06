describe "TreeCursor (neighbors and successors)", ->
  tree = """
           A
         /   ∖
       B       C 
     /  ∖     /  ∖
    D    E   F    G
  """

  examples = Helpers.TreeTestExamples.create [
    "node                   of A is A",
    "firstChild             of A is B",
    "firstChild             of B is D",
    "parent                 of B is A",
    "parent                 of E is B",
    "rightSibling           of B is C",
    "leftSibling            of C is B",
    "rightmostSibling       of B is C",
    "leftmostSibling        of C is B",
    "lastChild              of A is C",
    "root                   of E is A",
    "successor              of A is B",
    "successor              of B is D",
    "successor              of D is E",
    "successor              of E is C",
    "successor              of C is F",
    "predecessor            of E is D",
    "predecessor            of C is G",
    "predecessor            of F is B",
    "successorAtSameDepth   of B is C",
    "successorAtSameDepth   of E is F",
    "predecessorAtSameDepth of C is B",
    "predecessorAtSameDepth of F is E",
    "leafSuccessor          of E is F",
    "leafSuccessor          of B is D",
    "leafPredecessor        of F is E",
    "leafPredecessor        of C is G"
  ]

  cursors = null

  beforeEach ->
    cursors = getListOfCursorsIn Helpers.AsciiTreeParser.parse tree

  describe "when cursor is not volatile", ->
    it "should memoize preceding parent", ->
      cache = (cursors.get "B").getMemoized "parent"
      expect(cache.get "name").to.equal "A"

    it "should memoize 'null' if preceding sibling doesn't exist", ->
      cache = (cursors.get "B").getMemoized "leftSibling"
      expect(cache).to.equal null

    it "should memoize preceding sibling", ->
      cache = (cursors.get "C").getMemoized "leftSibling"
      expect(cache).to.equal cursors.get 'B'

  describe "when cursor is volatile", ->
    beforeEach ->
      node = Helpers.AsciiTreeParser.parse tree
      node.set 'cursor.isVolatile', yes
      cursors = getListOfCursorsIn node

    it "should not memoize preceding parent", ->
      cache = (cursors.get "B").getMemoized "parent"
      expect(cache).to.equal undefined

    it "should propagate tree-wide properties", ->
      pool = cursors.get "B.cursorPool"
      expect(pool).to.equal cursors.get "A.cursorPool"

    it "should not memoize preceding sibling", ->
      cache = (cursors.get "C").getMemoized "leftSibling"
      expect(cache).to.equal undefined

  examples.each (method, examples) ->
    describe "##{method}", ->
      it "should find #{method}", ->
        for [node, result] in examples
          expect( cursors.get "#{node}.#{method}.name" ).to.equal result

  describe "#parent", ->
    it "should not find parent of root", ->
      expect(cursors.get "A.parent").to.not.exist

  describe "#children", ->
    it "should find children", ->
      children = cursors.get "B.children"
      expect(getNamesOfNodes children).to.have.members ["D", "E"]

  describe "#successor", ->
    it "should not find successor of rightmost node at lowest depth", ->
      expect(cursors.get "G.successor").to.not.exist

  describe "#predecessor", ->
    it "should not find predecessor of leftmost node at lowest depth", ->
      expect(cursors.get "D.predecessor").to.not.exist

  describe "#upwardSuccessor", ->
    it "should find upwardSuccessor", ->
      expect(cursors.get "D.upwardSuccessor.name").to.equal "C"

  describe "#upwardPredecessor", ->
    it "should find upwardPredecessor", ->
      expect(cursors.get "G.upwardPredecessor.name").to.equal "B"
