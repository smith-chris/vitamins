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

    it "Should'nt generate groups with duplicated numbers", ->
      groups = JSON.stringify Node.makeGroups(input: "3g 3g 4g 4g", possibleGroups: possibleGroups)

      expect(groups).to.equal('{"B":[],"G":[3,4],"W":[]}')

    it "Should sort groups", ->
      groups = JSON.stringify Node.makeGroups(input: "1w 3g 2w 4g", possibleGroups: possibleGroups)

      expect(groups).to.equal('{"B":[],"G":[3,4],"W":[1,2]}')

    it "Should ignore additional groups", ->
      groups = Node.makeGroups(input: "3g 4w 2c 1w 5a", possibleGroups: possibleGroups)

      expect(groups).to.deep.equal({B: [], W: [1, 4], G: [3]})

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

      id = Node.generateId(input: randomizeId("3g 4w 2c 4e 6g 2c 1w 5a"), possibleGroups: possibleGroups)
      console.log id

      expect(id).to.equal("G3G6W1W4")

  node1input = "3g 4g 5w"
  node1 = new Node(input: node1input, possibleGroups: possibleGroups)

  describe ".state()", ->
    it "Should be equal to input string", ->
      expect(node1.state()).to.equal(node1input.toUpperCase())

  describe ".possibleSwaps()", ->
    it "Should return correct swaps", ->
      expect(node1.possibleSwaps()).to.deep.equal([[4, 'G', 'B'], [5, 'W', 'B'], [5, 'W', 'G']])

  node1child = node1.applySwap(node1.possibleSwaps()[0])
  describe ".applySwap()", ->
    it "Should return new node with new id after applying swap", ->
      expect(node1child).to.not.equal(node1)

      expect(node1child.id).to.equal("B4G3W5")

  describe ".states()", ->
    it "Should return list of all states in branch", ->
      expect(node1child.states()).to.deep.equal(JSON.stringify([node1.state(),node1child.state()]))

  describe ".swaps()", ->
    it "Should return list of all states in branch", ->
      expect(node1child.swaps()).to.deep.equal(JSON.stringify([node1.possibleSwaps()[0]]))

describe "NodeWalker", ->
  nodeWalker = new NodeWalker(possibleGroups: possibleGroups)

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