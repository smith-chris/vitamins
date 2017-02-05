module.exports = class Node
  constructor: ({input, groups, possibleGroups, @parent, @swap, filter}) ->
    if groups
      @groups = groups
    else
      @groups = Node.makeGroups({input: input, possibleGroups: possibleGroups, filter: filter})
    @id = Node.generateId(input: @groups)

  @generateId: ({input, groups, possibleGroups, filter}) ->
    if typeof input is "string"
      if not possibleGroups
        groups = Node.makeGroups({input: input, limited: false, filter: filter})
      else
        groups = Node.makeGroups({input: input, possibleGroups: possibleGroups, filter: filter})
    else
      groups = input
    result = ""
    for key, value of groups
      for e in value
        result += key + e
    return result

  @makeGroups: ({input, groups, possibleGroups, limited = true, filter}) ->
    result = {}
    if typeof possibleGroups is "string" and possibleGroups.length > 0
      for group in possibleGroups.split("").sort()
        result[group.toUpperCase()] = []
    else
      if limited
        throw new Error("At least one possible group should be provided when limited is set to true.")
    if input
      for elem in input.split /[ ]+/
        [all, number, group] = elem.match /([0-9]*)([\w]*)/
        if number and group
          isAcceptable = true
          if filter
            isAcceptable = filter(number, group)
          if isAcceptable
            group = group.toUpperCase()
            number = parseInt(number)

            if not limited
              if not result[group]
                result[group] = []

            if result[group] and result[group].indexOf(number) is -1
              result[group].push(number)

      for key, value of result
        value.sort()

    return result

  match: (id) ->
    if @id is id
      return @
    else return null

  lastInGroup: (e) ->
    if e.length > 0
      return e[e.length - 1]
    return 0

  compute: -> @applySwaps(@possibleSwaps())

  possibleSwaps: ->
    result = []
    for key, value of @groups
      last = @lastInGroup(value)

      if last > 0
        for k1, v1 of @groups
          if v1 isnt value
            last1 = @lastInGroup(v1)
            if last > last1
              result.push [last, key, k1]
    return result

  cloneGroups: ->
    result = {}
    for key, value of @groups
      result[key] = value.slice(0)
    return result

  forEachInBranch: (callback) ->
    callback(this)
    currentParent = @parent
    while currentParent
      callback(currentParent)
      currentParent = currentParent.parent

  swaps: ->
    result = []
    @forEachInBranch (node) ->
      if node.swap
        result.push node.swap
    return JSON.stringify(result.reverse())

  state: ->
    result = ""
    for key, value of @groups
      for e in value
        result += e + key + " "
    return result.trim()

  states: ->
    result = []
    @forEachInBranch (node) ->
      result.push node.state()
    return JSON.stringify(result.reverse())

  applySwapsSequentially: (swaps) ->
    currentNode = this
    for swap in swaps
      if not currentNode?
        return null
      currentNode = currentNode.applySwap(swap)
    return currentNode

  applySwap: (swap) ->
    fromGroup = @groups[swap[1]]
    toGroup = @groups[swap[2]]
    fromGroupTopNum = @lastInGroup(fromGroup)
    if fromGroup and toGroup and swap[0] is fromGroupTopNum
      toGroupTopNum = @lastInGroup(toGroup)
      if fromGroupTopNum > toGroupTopNum
        newGroups = @cloneGroups()
        newGroups[swap[2]].push(newGroups[swap[1]].pop())
        return new Node(groups: newGroups, parent: @, swap: swap)
    return null

  applySwaps: (swaps) ->
    result = []
    for swap in swaps
      newNode = @applySwap(swap)
      if newNode?
        result.push newNode
    return result