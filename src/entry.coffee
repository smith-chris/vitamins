class NodeList
  constructor: (@list = []) ->

  push: (e) -> @list.push(e)

  compute: ->
    newList = []
    for e in @list
      newList = newList.concat(e.compute(false))
    return new NodeList(newList)

  match: (id) ->
    for e in @list
      match = e.match(id)
      if match
        return match
    return null

class Node
  constructor: ({input, groups, @parent}) ->
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

  compute: (returnNodeList = true) -> @applyActions(@actions(), returnNodeList)

  actions: ->
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

  hasIdenticalParent: ->
    currentParent = @parent
    while currentParent
      if currentParent.id is @id
        return true
      currentParent = currentParent.parent
    return false

  applyActions: (actions, returnNodeList) ->
    if returnNodeList
      res = new NodeList()
    else
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
          newNode = new Node(groups: newGroups, parent: @)
          if not newNode.hasIdenticalParent()
            res.push newNode
    return res

#input = "4g 3g"
input = "3b 4b 5b 6b"
#target = "4w 3w"
target = "3w 4w 5w 6w"
possibleGroups = "gwb"

nodes = new Node input: input, groups: possibleGroups

targetId = Node.generateId(target)

moves = 0
while true
  moves++
  console.log nodes
  if moves > 18
    console.log "Uups! Too many moves"
    break
  nodes = nodes.compute()
  match = nodes.match(targetId)
  if match
    console.log "WIN! Moves: #{moves}"
    console.log match
    break

