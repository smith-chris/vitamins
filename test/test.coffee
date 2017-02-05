expect = require("chai").expect

Node = require "../src/Node.coffee"
NodeList = require "../src/NodeList.coffee"
NodeWalker = require "../src/NodeWalker.coffee"
possibleGroups = "bwg"

describe "Node", ->
  describe ".makeGroups()", ->
    it "Should fail when no possibleGroups argument is provided and limited is set to true(default)", ->
      expect(-> Node.makeGroups(input: "3g 4g")).to.throw(Error)

    it "Should generate groups", ->
      groups = JSON.stringify Node.makeGroups(input: "3g 4g", possibleGroups: possibleGroups)

      expect(groups).to.equal('{"B":[],"G":[3,4],"W":[]}')

    it "Should sort groups", ->
      groups = JSON.stringify Node.makeGroups(input: "1w 3g 2w 4g", possibleGroups: possibleGroups)

      expect(groups).to.equal('{"B":[],"G":[3,4],"W":[1,2]}')

    it "Should ignore additional groups", ->
      groups = Node.makeGroups(input: "3g 4w 2c 1w 5a", possibleGroups: possibleGroups)

      expect(groups).to.deep.equal({B: [], W: [1, 4], G: [3]})

    it "But should accept additional groups when limited is set to false", ->
      groups = Node.makeGroups(input: "3g 4w 2c 1w 5a", limited: false)

      expect(groups).to.deep.equal({G: [3], W: [1, 4], C: [2], A: [5]})

  randomizeId = (id) ->
    id = id.split(" ")
    result = ""
    while id.length > 0
      randomIndex = Math.floor(Math.random() * id.length)
      result += id.splice(randomIndex, 1)[0] + " "
    return result

  describe ".generateId()", ->
    it "Should generate correct ID", ->
      id = Node.generateId(input: "3g 4w 2c 1w 5a", possibleGroups: possibleGroups)

      expect(id).to.equal("G3W1W4")

    it "Should generate correct ID no matter in what order groups are written in input string", ->
      id = Node.generateId(input: randomizeId("3g 4w 2c 1w 5a"), possibleGroups: possibleGroups)

      expect(id).to.equal("G3W1W4")

      id = Node.generateId(input: randomizeId("3g 4w 1b 2c 4e 6g 2c 1w 5a"), possibleGroups: possibleGroups)

      expect(id).to.equal("B1G3G6W1W4")

describe "NodeWalker", ->
  nodeWalker = new NodeWalker(possibleGroups)

  describe ".makeAllWhite()", ->
    input = "3g 4g"
    it "Should return correct json string", ->
      jsonOutput = nodeWalker.makeAllWhite(input)

      expect(jsonOutput).to.equal('[[4,"G","B"],[3,"G","W"],[4,"B","W"]]')