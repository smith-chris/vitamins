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
      if input.length > 0
        message = "'#{input}' is not a valid value for this field."
      else
        message = "This field cannot be empty."
      validate.error(input, message)
      return false

    else
      input = input.toUpperCase().trim().split(/[ ]+/).join(" ")
      isValid = input is node.state()
      if isValid
        validate.success(node)
      else
        validate.success(node)
        validate.warning(node, "Did you meant '#{node.state()}'?")
      return true

  validateOperations: ({operations, node, validate}) ->
    if operations?.length > 0
      try
        operationsParsed = JSON.parse(operations.toUpperCase())
      catch err
        validate.error err, err.toString()
        return
      if operationsParsed
        if not Array.isArray(operationsParsed)
          validate.error(operationsParsed, 'A value of this field should be an array. For example [["4","G","W"]].')
        else
          data = node.applySwapsSequentially(operationsParsed, validate)
          console.log data
          console.log node
          console.log operationsParsed
          if data.node
            validate.error(data, "Couldnt perform operation #{data.index} - [#{JSON.stringify(data.swap)}] on vitamin line - [#{data.node.state()}]")
          else
            validate.success(data)
    else
      validate.error(operations, "This field cannot be empty.")

  generateId: (input) ->
    Node.generateId(input: input, possibleGroups: @possibleGroups, filter: @filter)

  makeGroups: (input) ->
    Node.makeGroups(input: input, possibleGroups: @possibleGroups, filter: @filter)

  validatePossibleToFind: ({startNode, endNode, validate}) ->
    data =
      startNumbers: startNode.groupsToNumbers()
      endNumbers: endNode.groupsToNumbers()
    if data.startNumbers.length isnt data.endNumbers.length
      validate.error(data, "Vitamins inital state (#{data.startNumbers.length} elements) should have the same amount of elements as end state (#{data.endNumbers.length} elements).")
    else if data.startNumbers.join(",") isnt data.endNumbers.join(",")
      validate.error(data, "Vitamins in initial state do not match end state vitamins.")
    else
      validate.success(data)



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
