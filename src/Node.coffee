# The **Node** class instance represents single state of Vitamins line.
#
# It takes either `{input: string, possibleGroups: string}` arguments to generate `@groups`
# or `@groups: object` argument.
#
# `@parent: Node` and `@swap: string` arguments are used further for branch related computation.
# Branch meaning all nodes from initial node to current node.
#
# `@groups` contains current vitamin color and numbers information.

module.exports = class Node
  constructor: ({input, @groups, possibleGroups, filter, @parent, @swap}) ->
    if not @groups
      @groups = Node.makeGroups({input: input, possibleGroups: possibleGroups, filter: filter})
    @id = Node.generateId(groups: @groups)


  # `static` **generateId()** returns unique string based on groups object.
  #
  # It takes either `{input: string, possibleGroups: string}` arguments to generate groups
  # or `{groups: object}` argument that contains vitamin color and numbers information.

  @generateId: ({groups, input, possibleGroups, filter}) ->
    if typeof input is "string"
      groups = Node.makeGroups({input: input, possibleGroups: possibleGroups, filter: filter})
    result = ""
    for key, value of groups
      for e in value
        result += key + e
    return result


  # `static` **makeGroups()** returns object that contains vitamin color and numbers information
  #
  # It takes `{input: string, possibleGroups: string}` arguments to generate groups.
  # For example:
  #
  #     {input: "3g 4g", possibleGroups: "bgw"}
  # will return:
  #
  #     {G: [3, 4]}

  @makeGroups: ({input, possibleGroups, filter}) ->
    result = {}
    if typeof possibleGroups is "string" and possibleGroups.length > 0
      for group in possibleGroups.split("").sort()
        result[group.toUpperCase()] = []
    else
      throw new Error("At least one possible group should be provided.")
    if input
      usedNumbers = []
      for elem in input.trim().split /[ ]+/
        [all, number, group] = elem.match /([0-9]*)([\w]*)/
        if number and group
          isAcceptable = true
          # Optionally filter can be used to filter out unwanted elements.
          if filter
            isAcceptable = filter(number, group)
          if isAcceptable
            group = group.toUpperCase()
            number = parseInt(number)

            if result[group] and result[group].indexOf(number) is -1 and usedNumbers.indexOf(number) is -1
              usedNumbers.push(number)
              result[group].push(number)

      for key, value of result
        value.sort()

    return result


  # **groupsToNumbers()** returns an array of numbers contained in `@groups` object properties.

  groupsToNumbers: ->
    result = []
    for key, value of @groups
      for number in value
        result.push number
    return result.sort()

  match: (id) ->
    if @id is id
      return @
    else return null


  # **topInGroup()** returns highest number in given array.

  topInGroup: (e) ->
    if e
      if e.length > 0
        return e[e.length - 1]
      return 0
    else
      console.log "return null"
      return null


  # **compute()** returns an array of nodes that all possible swaps could produce.

  compute: -> @applySwaps(@possibleSwaps())


  # **possibleSwaps()** returns an array of possible swap operations on this node.

  possibleSwaps: ->
    result = []
    for key, value of @groups
      last = @topInGroup(value)

      if last > 0
        for k1, v1 of @groups
          if v1 isnt value
            last1 = @topInGroup(v1)
            if last > last1
              result.push [last, key, k1]
    return result

  cloneGroups: ->
    result = {}
    for key, value of @groups
      result[key] = value.slice(0)
    return result


  # **forEachInBranch()** performs an action(callback function) on all nodes in branch,
  # starting from current node and finishing on initial node.

  forEachInBranch: (callback) ->
    callback(this)
    currentParent = @parent
    while currentParent
      callback(currentParent)
      currentParent = currentParent.parent


  # **swaps()** returns a JSON Array of swap operation performed on all nodes in branch,
  # starting from initial node and finishing on current node.

  swaps: ->
    result = []
    @forEachInBranch (node) ->
      if node.swap
        result.push node.swap
    return JSON.stringify(result.reverse())


  # **state()** returns a string representing Vitamins line state of this node.

  state: ->
    result = []
    for key, value of @groups
      for e in value
        result.push e + key
    return result.sort().join(" ")


  # **states()** returns a JSON Array of states of all nodes in branch,
  # starting from initial node and finishing on current node.

  states: ->
    result = []
    @forEachInBranch (node) ->
      result.push node.state()
    return JSON.stringify(result.reverse())

  # **.applySwapsSequentially()** returns a new Node with applied swap
  # operations one after another(always on resulting node).
  # If any of the given swaps cannot be applied it returns object containing information
  # on which swap operation failed and to what node this swap could'nt be applied.

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

  # **applySwaps()** returns an array of nodes each with applied separate swap operation.

  applySwaps: (swaps) ->
    result = []
    for swap in swaps
      newNode = @applySwap(swap)
      if newNode?
        result.push newNode
    return result