# The **Node** class instance represents state of Vitamins line.
#
# It takes `state: string, possibleGroups: string` arguments to generate `@groups`.
# It can take also `@groups: object` itself as an argument.
#
# `@groups` contains current vitamin color and number information.
#
# `@parent: Node` and `@swap: string` arguments are used further for branch related computation.
# Branch meaning all parents and nth-grand parents up to initial node.

module.exports = class Node
  constructor: ({state, @groups, possibleGroups, filter, @parent, @swap}) ->
    if not @groups
      @groups = Node.makeGroups({state: state, possibleGroups: possibleGroups, filter: filter})
    @id = Node.generateId(groups: @groups)


  # `static` **generateId()** returns unique string based on groups object.
  #
  # It takes `state: string, possibleGroups: string` arguments to generate `@groups`.
  # It can take also `@groups: object` itself as an argument.

  @generateId: ({groups, state, possibleGroups, filter}) ->
    if typeof state is "string"
      groups = Node.makeGroups({state: state, possibleGroups: possibleGroups, filter: filter})
    result = ""
    for groupName, groupArray of groups
      for number in groupArray
        result += groupName + number
    return result


  # `static` **makeGroups()** returns an object that contains vitamin color and number information
  #
  # It takes `state: string, possibleGroups: string` arguments to generate groups object.
  # For example:
  #
  #     {state: "3g 4g", possibleGroups: "bgw"}
  # will return:
  #
  #     {G: [3, 4]}

  @makeGroups: ({state, possibleGroups, filter}) ->
    groups = {}
    if typeof possibleGroups is "string" and possibleGroups.length > 0
      for groupName in possibleGroups.split("").sort()
        groups[groupName.toUpperCase()] = []
    else
      throw new Error("At least one possible group should be provided.")
    if state
      usedNumbers = []
      for elem in state.trim().split /[ ]+/
        [all, number, groupName] = elem.match /([0-9]*)([\w]*)/
        if number and groupName
          isAcceptable = true
          # Optionally `filter: function` can be used to filter out unwanted elements.
          if filter
            isAcceptable = filter(number, groupName)
          if isAcceptable
            groupName = groupName.toUpperCase()
            number = parseInt(number)

            if groups[groupName] and groups[groupName].indexOf(number) is -1
              if usedNumbers.indexOf(number) is -1
                usedNumbers.push(number)
                groups[groupName].push(number)

      for groupName, groupArray of groups
        groupArray.sort()

    return groups


  # **groupsToNumbers()** returns an array of numbers contained in `@groups` object properties.

  groupsToNumbers: ->
    result = []
    for groupName, groupArray of @groups
      for number in groupArray
        result.push number
    return result.sort()

  match: (id) ->
    if @id is id
      return @
    else return null


  # **topInGroup()** returns the highest number in the given array.

  topInGroup: (array) ->
    if array
      if array.length > 0
        return array[array.length - 1]
      return 0
    else
      return null


  # **compute()** returns an array of nodes all possible swaps could produce.

  compute: -> @applySwaps(@possibleSwaps())


  # **possibleSwaps()** returns an array of possible swap operations on this node.

  possibleSwaps: ->
    swaps = []
    for groupName1, groupArray1 of @groups
      topNumber1 = @topInGroup(groupArray1)

      if topNumber1 > 0
        for groupName2, groupArray2 of @groups
          if groupArray2 isnt groupArray1
            topNumber2 = @topInGroup(groupArray2)
            if topNumber1 > topNumber2
              swaps.push [topNumber1, groupName1, groupName2]
    return swaps

  cloneGroups: ->
    newGroups = {}
    for groupName, groupArray of @groups
      newGroups[groupName] = groupArray.slice(0)
    return newGroups


  # **forEachInBranch()** performs an action(callback function) on all nodes in the branch,
  # starting from current node and finishing on initial node.

  forEachInBranch: (callback) ->
    callback(this)
    currentParent = @parent
    while currentParent
      callback(currentParent)
      currentParent = currentParent.parent


  # **swaps()** returns a JSON Array of swap operation performed on all nodes in the branch,
  # starting from initial node and finishing on current node.

  swaps: ->
    swaps = []
    @forEachInBranch (node) ->
      if node.swap
        swaps.push node.swap
    return JSON.stringify(swaps.reverse())


  # **branch()** returns an array of nodes that contains this node, its parent and all its nth-grand parents.
  # Nodes in returned array start from maximum grand parent and ends on this node.

  branch: ->
    nodes = []
    @forEachInBranch (node) ->
      nodes.push node
    return nodes.reverse()

  # **state()** returns a string representing Vitamins line state of this node.

  state: ->
    elements = []
    for groupName, groupArray of @groups
      for number in groupArray
        elements.push number + groupName
    return elements.sort().join(" ")


  # **states()** returns a JSON Array of states of all nodes in the branch,
  # starting from initial node and finishing on current node.

  states: ()->
    states = []
    @forEachInBranch (node) ->
      states.push node.state()
    return JSON.stringify(states.reverse())

  # **applySwapsSequentially()** returns a new Node with applied swap
  # operations one after another(always on resulting node).
  # If any of the given swaps cannot be applied it returns on object containing information
  # on which swap operation failed and to what node this swap could not be applied.

  applySwapsSequentially: (swaps) ->
    currentNode = this
    for swap, i in swaps
      newNode = currentNode.applySwap(swap)
      if not newNode
        return {index: i + 1, swap: swap, node: currentNode}
      else
        currentNode = newNode
    return currentNode


  # **applySwap()** returns a new Node with applied swap operation.

  applySwap: (swap) ->
    if swap.length > 2
      fromGroup = @groups[swap[1]]
      toGroup = @groups[swap[2]]
      fromGroupTopNum = @topInGroup(fromGroup)
      if fromGroup? and toGroup? and parseInt(swap[0]) is fromGroupTopNum
        toGroupTopNum = @topInGroup(toGroup)
        if fromGroupTopNum > toGroupTopNum
          newGroups = @cloneGroups()
          newGroups[swap[2]].push(newGroups[swap[1]].pop())
          return new Node(groups: newGroups, parent: @, swap: swap)
    return null

  # **applySwaps()** returns an array of nodes, each with applied separate swap operation.

  applySwaps: (swaps) ->
    nodes = []
    for swap in swaps
      newNode = @applySwap(swap)
      if newNode?
        nodes.push newNode
    return nodes