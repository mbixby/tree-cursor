describe "TreeCursor (validations)", ->
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

  describe "#copyWithNewValidation", ->
    it "should reject nodes that don't pass condition", ->
      validated = (cursors.get "B").copyWithNewValidation 
        validate: (cursor) -> not (['D', 'E'].contains cursor.get 'name')
      expect((cursors.get 'C').copyIntoTree validated).to.exist
      expect((cursors.get 'D').copyIntoTree validated).to.not.exist
      expect((cursors.get 'E').copyIntoTree validated).to.not.exist

    it "should evaluate condition based on adjacent nodes", ->
      validated = (cursors.get "A").copyWithNewValidation
        validate: (cursor) -> not ('B' is cursor.get 'parent.name')
      expect((cursors.get 'C').copyIntoTree validated).to.exist
      expect((cursors.get 'D').copyIntoTree validated).to.not.exist
      expect((cursors.get 'E').copyIntoTree validated).to.not.exist

    it "should not mind recursive conditions", ->
      # Notice how the cursor gets validated against the original
      # tree, i.e. we can safely evaluate `x === cursors.get "A"`
      # The recursiveness in this example means that for E to be validated,
      # it needs to walk through its parent and root.
      validated = (cursors.get "E").copyWithNewValidation
        validate: (cursor) -> cursor isnt cursors.get "A"
      expect((cursors.get 'A').copyIntoTree validated).to.not.exist
      expect((cursors.get 'B').copyIntoTree validated).to.exist

    it "should be able to skip invalid cursors", ->
      validated = (cursors.get "A").copyWithNewValidation
        validate: (cursor) -> not ("B" is cursor.get 'name')
      # Notice how the representation of the tree loses its binary 
      # form but the underlying data stays the same
      children = (getNamesOfNodes validated.get 'children').join ' '
      expect(children).to.equal "D E C"

    it "should return null when the copied cursor becomes invalid", ->
      # We attempted to copy cursor "E" to the validated tree but since 
      # the "E" itself won't pass the validation, it won't exist 
      # in the validated tree. This is why it's useful to always 
      # validate the tree through the root cursor.
      validated = (cursors.get "E").copyWithNewValidation 
        validate: (cursor) -> 'E' isnt cursor.get 'name'
      expect(validated).to.not.exist

    it "should return for invalid cursor without a valid replacement", ->
      validated = (cursors.get "E").copyWithNewValidation {
        validate: (cursor) -> 'E' isnt cursor.get 'name'
      }, validReplacement: 'parent'
      expect(validated.get 'name').to.equal "B"
