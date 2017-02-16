expect = require("chai").expect

Node = require "../src/utils/Node.coffee"
NodeList = require "../src/utils/NodeList.coffee"
possibleGroups = "bwg"

describe "NodeList", ->
  describe "compute()", ->
    it "Should compute all possible nodes from initial node", ->
      nodeList = new NodeList(new Node(
        state:"3g 4g",
        possibleGroups: possibleGroups
      ))
      nodes = nodeList.compute().nodes
      expect(nodes[0].state()).to.equal("3G 4B")
      expect(nodes[1].state()).to.equal("3G 4W")
