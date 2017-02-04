Node = require "./Node.coffee"

module.exports = class NodeList
  constructor: ({input, groups}) ->
    @nodes = [new Node(input: input, groups: groups)]
    @idsCacheList = []

  isDuplicate: (node) ->
    for id in @idsCacheList
      if id is node.id
        return true
    return false

  compute: ->
    newList = []
    for node in @nodes
      newNodes = node.compute()
      for node in newNodes
        if not @isDuplicate(node)
          @idsCacheList.push node.id
          newList.push node
    @nodes = newList
    return @

  match: (id) ->
    for node in @nodes
      match = node.match(id)
      if match
        return match
    return null