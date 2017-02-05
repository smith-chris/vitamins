Node = require "./Node.coffee"

module.exports = class NodeList
  constructor: ({input, possibleGroups, groups, filter}) ->
    @nodes = [new Node(input: input, possibleGroups: possibleGroups, groups: groups, filter: filter)]
    @idsCacheList = []

  isDuplicate: (node) -> @idsCacheList.indexOf(node.id) >= 0

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