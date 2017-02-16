NodeList = require "./NodeList.coffee"
Node = require "./Node.coffee"


# The **NodeWalker** class instance contains set of methods for Node related computations.
#
# It takes `@possibleGroups` argument to define what type of Vitamins it can contain.
#
# Optionally it can take `@filter` argument for removing unwanted elements in Node creation.

module.exports = class NodeWalker
  constructor: ({@possibleGroups, @filter}) ->
    if not(typeof @possibleGroups is "string" and @possibleGroups.length > 0)
      throw new Error("At least one possible group should be provided.")


  # **makeAllWhite()** returns an array of swap operations needed to
  # make node white, meaning - put all numbers into 'W' group.

  makeAllWhite: (input) -> @find(input, NodeWalker.stateToWhite(input))?.swaps()

  @stateToWhite: (state) -> state.toUpperCase().replace(/[A-Z]/g, "W")

  # **getStates()** returns a JSON Array of all node states in branch.
  #
  # It takes `initial: string` to create initial node as a starting point.
  # Also either `operations: Array` or `target: string` is required.

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


  # **validateInput()** validates if all elements of given `input: string` will
  # be used when creating new Node from it.
  #
  # It takes `validate: Validator` argument to invoke success, warning and error events.

  validateInput: (input) ->
    node = new Node({input, possibleGroups: @possibleGroups, filter: @filter})
    isEmpty = node.id is ""
    if isEmpty
      if input.length > 0
        message = "'#{input}' is not a valid value for this field."
      else
        message = "This field cannot be empty."
      return type: "error", message: message, data: input

    else
      input = input.toUpperCase().trim().split(/[ ]+/).join(" ")
      isValid = input is node.state()
      if isValid
        return type: "success", data: node
      else
        return type: "warning", message: "Did you mean '#{node.state()}'?", data: node


  # **validateOperations()** validates if given `operations: Array` can be performed
  # on given `node: Node`.
  #
  # It takes `validate: Validator` argument to invoke success, warning and error events.

  validateOperations: ({operations, node}) ->
    if operations?.length > 0
      try
        operationsParsed = JSON.parse(operations.toUpperCase())
      catch error
        return type: "error", message: error.toString(), data: error
      if operationsParsed
        if not Array.isArray(operationsParsed)
          return type: "error", message: 'A value of this field should be an array. For example [["4","G","W"]].', data: operationsParsed
        else
          if operationsParsed.length is 0
            return type: "error", message: "Provide at least one swap operation to perform.", data: data
            return
          data = node.applySwapsSequentially(operationsParsed)
          if data.node
            return type: "error", message: "Could not perform operation #{data.index}
             - [#{JSON.stringify(data.swap)}] on vitamin state - [#{data.node.state()}]", data: data
          else
            return type: "success", message: "", data: data
    else
      return type: "error", message: "This field cannot be empty.", data: operations


  # **validateIsPossibleToFind()** validates if given `startNode: Node` can end up
  # (by performing swap operations) being a Node with a state of given `endNode: Node`.
  #
  # It takes `validate: Validator` argument to invoke success, warning and error events.

  validateIsPossibleToFind: ({startNode, endNode}) ->
    decline = (word, amount) -> return if amount > 1 then "#{word}s" else word
    data =
      startNode: startNode
      endNode: endNode
      startNumbers: startNode.groupsToNumbers()
      endNumbers: endNode.groupsToNumbers()
    if data.startNumbers.length isnt data.endNumbers.length
      message = "Vitamins inital state (#{data.startNumbers.length}
        #{decline("element", data.startNumbers.length)}) should have
        the same amount of elements as final state (#{data.endNumbers.length}
        #{decline("element", data.endNumbers.length)})."
      return type: "error", message: message, data: data
    else if data.startNumbers.join(",") isnt data.endNumbers.join(",")
      return type: "error", message: "Vitamins in initial state do not match end state vitamins.", data: data
    else
      return type: "success", message: "", data: data


  # **generateId()** returns unique string based on given `input: string`.

  generateId: (input) ->
    Node.generateId(input: input, possibleGroups: @possibleGroups, filter: @filter)


  # **makeGroups()** returns object that contains vitamin color and numbers information.

  makeGroups: (input) ->
    Node.makeGroups(input: input, possibleGroups: @possibleGroups, filter: @filter)


  # **find()** returns node with state as in `target: string` argument that was created by
  # performing one or more swap operations on node with state as in `input: string` argument.

  find: (input, target) ->
    nodes = new NodeList(new Node(input: input, possibleGroups: @possibleGroups, filter: @filter))
    targetId = @generateId(target)
    if targetId? and targetId isnt ""
      moves = 0
      while true
        moves++
        if moves > 500
          console.log "Uups! Too deep in Node tree.."
          return null
          break
        nodes = nodes.compute()
        matchedNode = nodes.match(targetId)
        if matchedNode
          return matchedNode
          break
