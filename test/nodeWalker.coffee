expect = require("chai").expect

Node = require "../src/Node.coffee"
NodeWalker = require "../src/NodeWalker.coffee"

describe "NodeWalker", ->
  nodeWalker = new NodeWalker(possibleGroups: "bwg")

  describe ".find()", ->
    target = "3w 4w 5w 6w"
    node = nodeWalker.find("3b 4b 5b 6b", target)
    it "Should return correct node", ->
      expect(node.state()).to.equal("3w 4w 5w 6w".toUpperCase())

    it "Should return correct node in least possible moves", ->
      expect(JSON.parse(node.swaps()).length).to.equal(15)

  describe ".makeAllWhite()", ->
    input = "3g 4g"
    it "Should return correct json string", ->
      jsonOutput = nodeWalker.makeAllWhite(input)

      expect(jsonOutput).to.equal('[[4,"G","B"],[3,"G","W"],[4,"B","W"]]')