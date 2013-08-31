describe "TreeCursor (position)", ->
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

  describe "#determinePositionAgainstCursor", ->
    it "should determine position against another cursor", ->
      examples = Helpers.Examples.create string: """
        position of B against C is left (i.e. B is left of C)
        position of C against B is right
        position of D against F is left
        position of D against C is left
        position of F against B is right
        position of A against B is top
        position of F against A is bottom
        position of A against A is undefined
      """
      actual = examples.map (line) ->
        (cursors.get line[2]).determinePositionAgainstCursor cursors.get line[4]
      expected = examples.map (line) -> line[6]
      expect(actual).to.equal expected


