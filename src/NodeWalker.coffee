NodeList = require "./NodeList.coffee"
Node = require "./Node.coffee"

module.exports = class NodeWalker
  constructor: ({@possibleGroups, @filter}) ->

  makeAllWhite: (input) -> @find(input, input.replace(/[a-z]/g, "w"))?.swaps()

  getStates: (initial, operations) ->
    node = new Node(input: initial, possibleGroups: @possibleGroups)
    node = node.applySwapsSequentially(operations)
    return node.states()

  generateId: (input) ->
    Node.generateId(input: input, possibleGroups: @possibleGroups, filter: @filter)

  makeGroups: (input) ->
    Node.makeGroups(input: input, possibleGroups: @possibleGroups, filter: @filter)

  find: (input, target) ->
    nodes = new NodeList(input: input, possibleGroups: @possibleGroups, filter: @filter)
    targetId = @generateId(target)
    if targetId? and targetId isnt ""
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
