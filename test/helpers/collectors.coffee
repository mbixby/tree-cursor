getNamesOfNodesInTree = (cursor) ->
  nodes = getAllNodesInTree cursor
  (getNamesOfNodes nodes).join ' '
  
getAllNodesInTree = (cursor) ->
  successorsOf = (cursor) ->
    return [] unless cursor
    [cursor].concat successorsOf cursor.get 'successor'
  successorsOf cursor

getNamesOfNodes = (nodes) -> 
  nodes.mapProperty 'name'

getJoinedNamesOfNodes = (nodes) -> 
  (getNamesOfNodes nodes).join ' '
