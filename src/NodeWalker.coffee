NodeList = require "./NodeList.coffee"
Node = require "./Node.coffee"

module.exports = class NodeWalker
  constructor: (@possibleGroups) ->

  makeAllWhite: (input) -> @find(input, input.replace(/[a-z]/g, "w")).swaps()

  find: (input, target) ->
    nodes = new NodeList(input: input, groups: @possibleGroups)
    targetId = Node.generateId(target)
    moves = 0
    while true
      moves++
      if moves > 500
        console.log "Uups! Too many moves"
        return null
        break
      nodes = nodes.compute()
      match = nodes.match(targetId)
      if match
        return match
        break
