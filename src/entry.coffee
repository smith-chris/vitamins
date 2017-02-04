class NodeList
  constructor: ({input, groups}) ->
    @nodes = [new Node(input: input, groups: groups)]
    @idsCacheList = []

  isDuplicate: (node) ->
    for id in @idsCacheList
      if id is node.id
        return true
    return false

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

class Node
  constructor: ({input, groups, @parent, @swap}) ->
    @groups = Node.makeGroups({input: input, groups: groups})
    @id = Node.generateId(@groups)

  @generateId: (input) ->
    if typeof input is "string"
      groups = Node.makeGroups({input: input, limited: false})
    else
      groups = input
    result = ""
    for key, value of groups
      for e in value
        result += key + e
    return result

  @makeGroups: ({input, groups = {}, limited = true}) ->
    if typeof groups is "string"
      result = {}
      for group in groups.split("")
        result[group.toUpperCase()] = []
    else
      result = groups
    if input
      for elem in input.split /[ ]+/
        [all, number, group] = elem.match /([0-9]*)([\w]*)/
        if number and group
          group = group.toUpperCase()

          if not limited
            if not result[group]
              result[group] = []

          if result[group]
            result[group].push(parseInt(number))

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

input = "4g 3g"
#input = "3b 4b 5b 6b"
target = "4w 3w"
#target = "3w 4w 5w 6w"
possibleGroups = "gwb"

node = new Node(input: "3g 4g", groups: possibleGroups)
console.log node
node = node.applySwapsSequentially([
  [4, "G", "B"],
  [3, "G", "W"],
  [4, "B", "W"]
])
console.log node.states()

nodes = new NodeList(input: input, groups: possibleGroups)

targetId = Node.generateId(target)

moves = 0
while true
  moves++
  console.log nodes
  if moves > 500
    console.log "Uups! Too many moves"
    break
  nodes = nodes.compute()
  match = nodes.match(targetId)
  if match
    console.log "WIN! Moves: #{moves}"
    console.log match.swaps()
    break