expect = require("chai").expect

Node = require "../src/utils/Node.coffee"
possibleGroups = "bwg"

describe "Node", ->
  describe ".makeGroups()", ->
    it "Should fail when no possibleGroups argument is provided and limited is set to true(default)", ->
      expect(-> Node.makeGroups(state: "3g 4g")).to.throw(Error)

    it "Should generate groups", ->
      groups = JSON.stringify Node.makeGroups(state: "3g 4g", possibleGroups: possibleGroups)

      expect(groups).to.equal('{"B":[],"G":[3,4],"W":[]}')

    it "Should'nt generate groups with duplicated numbers", ->
      groups = JSON.stringify Node.makeGroups(state: "3g 3g 4g 4g", possibleGroups: possibleGroups)

      expect(groups).to.equal('{"B":[],"G":[3,4],"W":[]}')

    it "Should sort groups", ->
      groups = JSON.stringify Node.makeGroups(state: "1w 3g 2w 4g", possibleGroups: possibleGroups)

      expect(groups).to.equal('{"B":[],"G":[3,4],"W":[1,2]}')

    it "Should ignore additional groups", ->
      groups = Node.makeGroups(state: "3g 4w 2c 1w 5a", possibleGroups: possibleGroups)

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
      id = Node.generateId(state: "3g 4w 2c 1w 5a", possibleGroups: possibleGroups)

      expect(id).to.equal("G3W1W4")

    it "Should generate correct ID no matter in what order groups are written in state string", ->
      id = Node.generateId(state: randomizeId("3g 4w 2c 1w 5a"), possibleGroups: possibleGroups)

      expect(id).to.equal("G3W1W4")

      id = Node.generateId(state: randomizeId("3g 4w 2c 4e 6g 2c 1w 5a"), possibleGroups: possibleGroups)

      expect(id).to.equal("G3G6W1W4")

  node1state = "3g 4g 5w"
  node1 = new Node(state: node1state, possibleGroups: possibleGroups)

  describe ".state()", ->
    it "Should be equal to state string", ->
      expect(node1.state()).to.equal(node1state.toUpperCase())

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
