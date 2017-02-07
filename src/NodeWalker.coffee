NodeList = require "./NodeList.coffee"
Node = require "./Node.coffee"

module.exports = class NodeWalker
  constructor: ({@possibleGroups, @filter}) ->

  makeAllWhite: (input) -> @find(input, input.replace(/[a-z]/g, "w"))?.swaps()

  getStates: ({initial, operations, target}) ->
    if initial
      if operations
        node = new Node(input: initial, possibleGroups: @possibleGroups)
        if node? and node.id isnt ""
          node = node.applySwapsSequentially(operations)
        else
          return null
      else if target
        node = @find(initial, target)
      return node.states()

  validateInput: (input, validate) ->
    node = new Node({input, possibleGroups: @possibleGroups, filter: @filter})
    isEmpty = node.id is ""
    if isEmpty
      validate.error(input)
      return false
    else
      input = input.toUpperCase().trim().split(/[ ]+/).join(" ")
      isValid = input is node.state()
      if isValid
        validate.success(node)
      else
        validate.warning(node)
        validate.success(node)
      return true

  validateOperations: ({operations, node, validate}) ->
    try
      operationsParsed = JSON.parse(operations.toUpperCase())
    catch err
      validate.error err.toString()
      return
    if operationsParsed
      node = node.applySwapsSequentially(operationsParsed, validate)
      if node.node
        validate.error(node)
      else
        validate.success(node)


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
