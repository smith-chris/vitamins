expect = require("chai").expect

Node = require "../src/utils/Node.coffee"
NodeWalker = require "../src/utils/NodeWalker.coffee"

describe "NodeWalker", ->
  nodeWalker = new NodeWalker(possibleGroups: "bwg")

  describe ".find()", ->
    target = "3w 4w 5w 6w"
    node = nodeWalker.find("3b 4b 5b 6b", target)
    it "Should return correct node", ->
      expect(node.state()).to.equal("3w 4w 5w 6w".toUpperCase())

    it "Should return correct node in least possible moves", ->
      expect(JSON.parse(node.swaps()).length).to.equal(15)

  describe ".makeAllWhite() [Exercise 1B]", ->
    state = "3g 4g"
    it "Should return correct json string", ->
      jsonOutput = nodeWalker.makeAllWhite(state)

      expect(jsonOutput).to.equal('[[4,"G","B"],[3,"G","W"],[4,"B","W"]]')

  describe ".getStates() [Exercise 3A]", ->
    it "Should return correct value", ->
      result = nodeWalker.getStates(
        initialState: "3g 4g"
        swapOperations: [
          [4, "G", "B"]
          [3, "G", "W"]
          [4, "B", "W"]
        ]
      )
      expect(result).to.equal('["3G 4G","3G 4B","3W 4B","3W 4W"]')