Node = require "Node"
NodeList = require "NodeList"

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

exports.test = "hollo"

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