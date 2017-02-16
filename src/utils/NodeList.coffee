Node = require "./Node.coffee"


# The **NodeList** class instance contains array of all possible and
# non-repetitive nodes at the same depth in nodes tree.
#
# It takes `initialNode: Node` as argument.
#
# `@idsCacheList` property stores all Node IDs this NodeList ever had at any depth.

module.exports = class NodeList
  constructor: (initialNode) ->
    if not initialNode instanceof Node
      throw new Error("You must provide top node to create NodeList.")
    @nodes = [initialNode]
    @idsCacheList = []


  # **isDuplicate()** returns `boolean` indicating whether given node was present in this NodeList at any depth.

  isDuplicate: (node) -> @idsCacheList.indexOf(node.id) >= 0


  # **compute()** replaces `@nodes` array property of this instance
  # with new array containing possible nodes in one level deeper depth.

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

  # **match()** returns `Node` matching given ID at current depth or `null` if match fails.

  match: (id) ->
    for node in @nodes
      matchedNode = node.match(id)
      if matchedNode
        return matchedNode
    return null