Node = require "Node"
NodeWalker = require "NodeWalker"
Validator = require "Validator"
VitaminLine = require("components/VitaminLine")
require "styles"

document.addEventListener "DOMContentLoaded", ->
  $ = document.querySelector.bind(document)
  $$ = document.querySelectorAll.bind(document)

  vitamins = new VitaminLine(
    vitamins: $$(".shapes svg")
    controlButton: $("#animate")
    data: -> swapOperationsValidation.data.branch()
  )

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


  onFormError = () ->
    vitamins.disable()

  onFormValidated = () ->
    vitamins.enable()

  $initialState = $("#initial-state")
  $swapOperations = $("#swap-operations")
  $finalState = $("#final-state")

  initialStateValidation = new Validator(
    elem: $initialState
    validate: (text) -> exerciseSolver.validateInput(text, @)
  )

  initialStateValidation.on "success", (node) ->
    vitamins.visualize(node.groups)
    swapOperationsValidation.validate()
    if swapOperationsValidation.valid
      onFormValidated()
    else
      finalStateValidation.validate()
      if finalStateValidation.valid
        onFormValidated()

  initialStateValidation.on "error", (data) ->
    onFormError()
    if !data or data is ""
      resetSvgs()


  swapOperationsValidation = new Validator(
    elem: $swapOperations
    validate: (text) ->
      if initialStateValidation.valid
        exerciseSolver.validateOperations(operations: text, validate: @, node: initialStateValidation.data)
      else
        @error(initialStateValidation.data, "You must pass correct value to input field to proceed.")
  )

  swapOperationsValidation.on "error", onFormError

  swapOperationsValidation.on "success", (data) ->
    if data isnt initialStateValidation.data
      $finalState.value = data.state()
      finalStateValidation.clearMessage()
      onFormValidated()


  finalStateValidation = new Validator(
    elem: $finalState
    validate: (text) ->
      if initialStateValidation.valid
        exerciseSolver.validateInput(text, @)
      else
        @error(initialStateValidation.data, "You must pass correct value to input field to proceed.")
  )

  finalStateValidation.on "error", onFormError

  finalStateValidation.on "success", (data) ->
    startNode = initialStateValidation.data
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
            onFormValidated()
            $swapOperations.value = endNode?.swaps()
            swapOperationsValidation.clearMessage()
            swapOperationsValidation.data = endNode
    )


#  $initialState.value = "3g 4g 5w 6b"
#  $initialState.value = "3g 4g"
#  initialStateValidation.validate()