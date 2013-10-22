# Helper method to make all cursors addressable by name
# Applicable for the basic binary tree shown in most tests
# (e.g. you can call cursors.get 'X.parent')
getListOfCursorsIn = (node) ->
  Ember.Object.createWithMixins
    "A": node.get 'cursor'
    "B": (-> @get 'A.firstChild' ).property()
    "C": (-> @get 'A.lastChild' ).property()
    "D": (-> @get 'B.firstChild' ).property()
    "E": (-> @get 'B.lastChild' ).property()
    "F": (-> @get 'C.firstChild' ).property()
    "G": (-> @get 'C.lastChild' ).property()

getNamesOfNodesInTree = (cursor) ->
  nodes = getAllNodesInTree cursor
  (getNamesOfNodes nodes).join ' '
  
getAllNodesInTree = (cursor) ->
  successorsOf = (cursor) ->
    return [] unless cursor
    [cursor].concat successorsOf cursor.get 'successor'
  successorsOf cursor

getNamesOfNodes = (nodes) -> 
  nodes.mapProperty 'node.name'

getJoinedNamesOfNodes = (nodes) -> 
  (getNamesOfNodes nodes).join ' '
