describe "TreeCursor (family)", ->
  tree = """
           A
         /   ∖
       B       C 
     /  ∖     /  ∖
    D    E   F    G
  """  

  cursors = null

  beforeEach ->
    cursors = getListOfCursorsIn Helpers.AsciiTreeParser.parse tree

  describe "#branch", ->
    it "should find branch", ->
      expect((cursors.get "E.branch").join ' ').to.equal "E B A"

  describe "#depth", ->
    it "should find depth", ->
      expect(cursors.get "E.depth").to.equal 2

  describe "#height", ->
    it "should find height", ->
      expect(cursors.get "E.height").to.equal 0
      expect(cursors.get "A.height").to.equal 2

  describe "#findClosestCommonAncestorWithCursor", ->
    it "should find closestCommonAncestorWithCursor", ->
      examples = Helpers.Examples.create string: """
        common ancestor of D and E is B
        common ancestor of D and F is A
        common ancestor of C and C is C
        common ancestor of A and C is A
      """
      actual = examples.map (line) ->
        (cursors.get line[3]).findClosestCommonAncestorWithCursor cursors.get line[5]
      expected = examples.map (line) -> line[7]
      expect(actual).to.equal expected

  describe "#findChildBelongingToBranch", ->
    it "should find childBelongingToBranch", ->
      parent = cursors.get "A"
      branch = cursors.get "G.branch"
      actual = parent.findChildBelongingToBranch branch
      expect(actual.get 'name').to.equal "C"

  describe "#findClosestSiblingAncestorsWithCursor", ->
    it "should find closestSiblingAncestorsWithCursor", ->
      ancestors = (cursors.get "D").findClosestSiblingAncestorsWithCursor cursors.get "G"
      expect(ancestors.join ' ').to.equal "B C"

    it "should not find closestSiblingAncestorsWithCursor on the same branch", ->
      ancestors = (cursors.get "A").findClosestSiblingAncestorsWithCursor cursors.get "B"
      expect(ancestors).to.equal undefined

