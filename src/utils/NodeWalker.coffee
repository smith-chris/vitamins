NodeList = require "./NodeList.coffee"
Node = require "./Node.coffee"


# The **NodeWalker** class instance contains set of methods for Node related computations.
#
# It takes `@possibleGroups` argument to define what type of Nodes it can create.
#
# Optionally it can take `@filter` argument for removing unwanted elements in Node creation.

module.exports = class NodeWalker
  constructor: ({@possibleGroups, @filter}) ->
    if not(typeof @possibleGroups is "string" and @possibleGroups.length > 0)
      throw new Error("At least one possible group should be provided.")


  # **makeAllWhite()** returns an array of swap operations needed to
  # make node white, meaning - put all numbers into 'W' group.

  makeAllWhite: (state) -> @find(state, NodeWalker.stateToWhite(state))?.swaps()


  # `static` **stateToWhite()** takes a state string and returns
  # similar state with all elements set to white.

  @stateToWhite: (state) -> state.toUpperCase().replace(/[A-Z]/g, "W")

  # **getStates()** returns a JSON Array string of all node states in branch.
  #
  # It takes `initialState: string` to create initial node as a starting point.
  # Also either `swapOperations: Array` or `finalState: string` argument is required.

  getStates: ({initialState, swapOperations, finalState}) ->
    if initialState
      if swapOperations
        node = new Node(state: initialState, possibleGroups: @possibleGroups)
        if node? and node.id isnt ""
          node = node.applySwapsSequentially(swapOperations)
        else
          return null
      else if finalState
        node = @find(initialState, finalState)
      return node.states()


  # **validateInput()** validates if all elements of given `state: string` will
  # be used when creating new Node from it.
  #
  # It returns object in format `type: string, message: string, data: any`
  # that can be processed further on by validator logic.

  validateState: (state) ->
    node = new Node({state, possibleGroups: @possibleGroups, filter: @filter})
    isEmpty = node.id is ""
    if isEmpty
      if state.length > 0
        message = "'#{state}' is not a valid value for this field."
      else
        message = "This field cannot be empty."
      return type: "error", message: message, data: state

    else
      state = state.toUpperCase().trim().split(/[ ]+/).join(" ")
      isValid = state is node.state()
      if isValid
        return type: "success", data: node
      else
        return type: "warning", message: "Do you mean '#{node.state()}'?", data: node


  # **validateOperations()** validates if given `operations: Array` can be performed
  # on given `node: Node`.
  #
  # It returns object in format `type: string, message: string, data: any`
  # that can be processed further on by validator logic.

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


  # **validateIsPossibleToFind()** validates if given `initialNode: Node` can end up
  # (by performing swap operations) being a Node with a state of given `finalNode: Node`.
  #
  # It returns object in format `type: string, message: string, data: any`
  # that can be processed further on by validator logic.

  validateIsPossibleToFind: ({initialNode, finalNode}) ->
    decline = (word, amount) -> return if amount > 1 then "#{word}s" else word
    data =
      initialNode: initialNode
      finalNode: finalNode
      initialNumbers: initialNode.groupsToNumbers()
      finalNumbers: finalNode.groupsToNumbers()
    if data.initialNumbers.length isnt data.finalNumbers.length
      initLength = data.initialNumbers.length
      finalLength = data.initialNumbers.length
      message = "Vitamins initial state (#{initLength}
        #{decline("element", initLength)}) should have
        the same amount of elements as final state (#{finalLength}
        #{decline("element", finalLength)})."
      return type: "error", message: message, data: data
    else if data.initialNumbers.join(",") isnt data.finalNumbers.join(",")
      return type: "error", message: "Vitamins in initial state do not match final state vitamins.", data: data
    else
      return type: "success", message: "", data: data


  # **generateId()** returns unique string based on given `state: string`.

  generateId: (state) ->
    Node.generateId(state: state, possibleGroups: @possibleGroups, filter: @filter)


  # **makeGroups()** returns object that contains vitamin color and numbers information.

  makeGroups: (state) ->
    Node.makeGroups(state: state, possibleGroups: @possibleGroups, filter: @filter)


  # **find()** returns node with state as in `targetState: string` argument that was created by
  # performing one or more swap operations on node with state as in `initialState: string` argument.

  find: (initialState, targetState) ->
    nodes = new NodeList(new Node(state: initialState, possibleGroups: @possibleGroups, filter: @filter))
    targetId = @generateId(targetState)
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
