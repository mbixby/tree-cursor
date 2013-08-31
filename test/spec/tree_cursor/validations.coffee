describe "TreeCursor (validations)", ->
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

  describe "#addValidation", ->
    it "should reject nodes that don't pass condition", ->
      cursor = (cursors.get "E").addValidation 
        validate: (cursor) -> not (['D', 'E'].contains cursor.get 'name')
        shouldSkipInvalidCursors: no
      expect(cursor.get 'A.firstChild.firstChild').to.not.exist

    it "should evaluate condition based on adjacent nodes", ->
      cursor = (cursors.get "E").addValidation
        validate: (cursor) -> not ('B' is cursor.get 'parent.name')
        shouldSkipInvalidCursors: no
      expect(cursor.get 'A.firstChild.firstChild').to.not.exist

    it "should not mind recursive conditions", ->
      cursor = (cursors.get "A").addValidation
        validate: (cursor) -> cursor is cursors.get "A"
        shouldSkipInvalidCursors: no
      expect(cursor.get 'A').to.not.exist

    it "should be able to skip invalid cursors", ->
      cursor = (cursors.get "A").addValidation
        validate: (cursor) -> not ("B" is cursor.get 'name')
        shouldSkipInvalidCursors: yes
      # Notice how the representation of the tree loses its binary 
      # form but the underlying data stays the same
      children = (getNamesOfNodes cursors.get 'A.children').join ' '
      expect(children).to.equal "D E C"
