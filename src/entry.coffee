Node = require "Node"
NodeList = require "NodeList"
NodeWalker = require "NodeWalker"

possibleGroups = "gwb"

node = new Node(input: "3g 4g", groups: possibleGroups)
console.log node
node = node.applySwapsSequentially([
  [4, "G", "B"],
  [3, "G", "W"],
  [4, "B", "W"]
])
console.log node.states()

input = "4g 3g"

exerciseSolver = new NodeWalker(possibleGroups)

# Exercise 1B
console.log exerciseSolver.makeAllWhite(input)