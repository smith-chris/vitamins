Node = require "Node"
NodeWalker = require "NodeWalker"
Validator = require "Validator"
require "styles"

document.addEventListener "DOMContentLoaded", ->
  $ = document.querySelector.bind(document)
  $$ = document.querySelectorAll.bind(document)

  exerciseSolver = new NodeWalker(
    possibleGroups: "gwb"
    filter: (num) -> num > 2 and num < 7
  )

  # Exercise 1B
  console.log exerciseSolver.makeAllWhite("3g 4g")

  # Exercise 3A
  console.log exerciseSolver.getStates(
    initial: "3g 4g"
    operations: [
      [4, "G", "B"]
      [3, "G", "W"]
      [4, "B", "W"]
    ]
  )
  $svgs = $$(".shapes svg")

  resetSvgs = () ->
    for e in $svgs
      e.classList = []

  visualize = (groups) ->
    resetSvgs()
    for key, val of groups
      for num in val
        applyColor(num, key)

  applyColor = (num, color) ->
    $svgs[num - 3].classList = [color]

  $vitaminInput = $("#vitamin-input")
  $vitaminOperations = $("#vitamin-operations")
  $vitaminOutput = $("#vitamin-output")

  inputValidation = new Validator(
    elem: $vitaminInput
    validate: (text) -> exerciseSolver.validateInput(text, @)
  )

  inputValidation.on "success", (node) ->
    visualize(node.groups)

  inputValidation.on "error", (data) ->
    if !data or data is ""
      resetSvgs()

  $vitaminInput.value = "3g 4g"
  inputValidation.validate()

  operationsValidation = new Validator(
    elem: $vitaminOperations
    validate: (text) ->
      if inputValidation.valid
        exerciseSolver.validateOperations(operations: text, validate: @, node: inputValidation.data)
      else
        @error(inputValidation.data, "You must pass correct value to input field to proceed.")
        # TODO hook an one-time event on inputValidation success that will validate this field again
  )

  operationsValidation.on "success", (data) ->
    if data isnt inputValidation.data
      console.log "Operations validated!"
      $vitaminOutput.value = data.state()


  outputValidation = new Validator(
    elem: $vitaminOutput
    validate: (text) ->
      if inputValidation.valid
        exerciseSolver.validateInput(text, @)
      else
        @error(inputValidation.data, "You must pass correct value to input field to proceed.")
        # TODO hook an one-time event on inputValidation success that will validate this field again
  )

  outputValidation.on "success", (data) ->
    startNode = inputValidation.data
    endNode = data
    exerciseSolver.validateIsPossibleToFind(
      startNode: startNode
      endNode: endNode
      validate:
        error: @error.bind(@)
        success: =>
          console.log "All successful"
          endNode = exerciseSolver.find(startNode.state(), endNode.state())
          if endNode
            # TODO enable animate button
            $vitaminOperations.value = endNode?.swaps()
    )