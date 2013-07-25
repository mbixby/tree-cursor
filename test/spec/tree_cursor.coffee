require 'helpers/*'

describe "TreeCursor", ->
  tree = TreeNode.create ascii: """
           A
         /   \
       B       C
     /  \     / \
    D    E   F    G
  """

  examples = TreeTestExamples.create [
    "node                   of A is A",
    "firstChild             of A is B",
    "firstChild             of B is D",
    "parent                 of B is A",
    "rightSibling           of B is C",
    "leftSibling            of C is B",
    "rightmostSibling       of B is C",
    "leftmostSibling        of C is B",
    "lastChild              of A is C",
    "successor              of A is B",
    "successor              of B is D",
    "successor              of D is E",
    "successor              of E is C",
    "successor              of C is F",
    "predecessor            of E is D",
    "predecessor            of F is B",
    "predecessor            of C is G",
    "successorAtSameDepth   of B is C",
    "successorAtSameDepth   of E is F",
    "predecessorAtSameDepth of C is B",
    "predecessorAtSameDepth of F is E",
    "leafSuccessor          of E is F",
    "leafSuccessor          of B is D",
    "leafPredecessor        of F is E",
    "leafPredecessor        of C is G",
    "root                   of E is A"
  ]

  rootCursor = ArrayTreeCursor.create { node: tree }
  cursors = {}

  beforeEach ->
    cursors = (Ember.Object.extend
      "A": (-> rootCursor ).property()
      "B": (-> @get 'A.firstChild' ).property()
      "C": (-> @get 'A.lastChild' ).property()
      "D": (-> @get 'B.firstChild' ).property()
      "E": (-> @get 'B.lastChild' ).property()
      "F": (-> @get 'C.firstChild' ).property()
      "G": (-> @get 'C.lastChild' ).property()
    ).create()

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
      names = children.map (b) -> b.get 'name'
      expect(names).to.have.members ["D", "E"]

  describe "#successor", ->
    it "should not find successor of G", ->
      expect(cursors.get "G.successor").to.not.exist

  describe "#predecessor", ->
    it "should not find predecessor of D", ->
      expect(cursors.get "D.predecessor").to.not.exist

  describe "#findUpwardSuccessor", ->
    it "should find upwardSuccessor", ->
      [cursor, _] = (cursors.get "D").findUpwardSuccessorAndItsDepth()
      expect(cursor.get "name").to.equal "C"

  describe "#findUpwardPredecessor", ->
    it "should find upwardPredecessor", ->
      [cursor, _] = (cursors.get "G").findUpwardPredecessorAndItsDepth()
      expect(cursor.get "name").to.equal "B"



