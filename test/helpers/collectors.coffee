getNamesOfNodesInTree = (cursor) ->
  nodes = getAllNodesInTree cursor
  names = nodes.mapProperty 'name'
  names.join ' '
  
getAllNodesInTree = (cursor) ->
  successorsOf = (cursor) ->
    return [] unless cursor
    [cursor].concat successorsOf cursor.get 'successor'
  successorsOf cursor

getNamesOfNodes = (nodes) -> 
  nodes.mapProperty 'name'
