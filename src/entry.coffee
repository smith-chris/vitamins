class NodeList
  constructor: ({input, groups}) ->
    @list = [new Node(input: input, groups: groups)]
    @idsList = []

  push: (e) -> @list.push(e)

  isDuplicate: (node) ->
    for e in @idsList
      if e is node.id
        return true
    return false

  compute: ->
    newList = []
    for e in @list
      newNodes = e.compute()
      for node in newNodes
        if not @isDuplicate(node)
          @idsList.push node.id
          newList.push node
    @list = newList
    return @

  match: (id) ->
    for e in @list
      match = e.match(id)
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
    res = ""
    for k, v of groups
      for e in v
        res += k + e
    return res

  @makeGroups: ({input, groups = {}, limited = true}) ->
    if typeof groups is "string"
      res = {}
      for e in groups.split("").sort()
        res[e.toUpperCase()] = []
    else
      res = groups
    if input
      for e in input.split /[ ]+/
        [all, number, group] = e.match /([0-9]*)([\w]*)/
        if number and group
          group = group.toUpperCase()

          if not limited
            if not res[group]
              res[group] = []

          if res[group]
            res[group].push(parseInt(number))

      for k, v of res
        v.sort()

    return res

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
    res = []
    for k, v of @groups
      last = @lastInGroup(v)

      if last > 0
        for k1, v1 of @groups
          if v1 isnt v
            last1 = @lastInGroup(v1)
            if last > last1
              res.push [last, k, k1]
    return res

  cloneGroups: ->
    res = {}
    for k, v of @groups
      res[k] = v.slice(0)
    return res

  forEachInBranch: (callback) ->
    callback(this)
    currentParent = @parent
    while currentParent
      callback(currentParent)
      currentParent = currentParent.parent

  swaps: ->
    res = []
    @forEachInBranch (node) ->
      if node.swap
        res.push node.swap
    return JSON.stringify(res.reverse())

  applySwaps: (actions) ->
    res = []
    for e in actions
      from = @groups[e[1]]
      to = @groups[e[2]]
      fromLast = @lastInGroup(from)
      if from and to and e[0] is fromLast
        toLast = @lastInGroup(to)
        if fromLast > toLast
          newGroups = @cloneGroups()
          newGroups[e[2]].push(newGroups[e[1]].pop())
          res.push new Node(groups: newGroups, parent: @, swap: e)
    return res

input = "4g 3g"
#input = "3b 4b 5b 6b"
target = "4w 3w"
#target = "3w 4w 5w 6w"
possibleGroups = "gwb"

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