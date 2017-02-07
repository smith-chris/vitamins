Node = require "Node"
NodeWalker = require "NodeWalker"
Validator = require "Validator"

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
    validate: (text, validate) -> exerciseSolver.validateInput(text, validate)
    errorMessage: (data) ->
      if data.length > 0
        return "'#{data}' is not a valid input for this field."
      else
        return "This field cannot be empty."
    warningMessage: (data) -> console.log "Did you meant '#{data.state()}'?"
  )

  inputValidation.on "success", (node) ->
    console.log "Input validated!"
    visualize(node.groups)

  $vitaminInput.value = "3g 4g"
  inputValidation.validate()

  operationsValidation = new Validator(
    elem: $vitaminOperations
    validate: (text, validate) ->
      if inputValidation.valid
        exerciseSolver.validateOperations(operations: text, validate: validate, node: inputValidation.data)
      else
        console.log "input not valid"

    errorMessage: (data) ->
      if data.node
        return "Couldnt perform operation #{data.index} - [#{data.swap}] on vitamin line - [#{data.node.state()}]"
      else
        return data
    warningMessage: (data) -> console.log "Did you meant '#{data}'?"
  )

  operationsValidation.on "success", (data) ->
    if data isnt inputValidation.data
      console.log "Operations validated!"
      $vitaminOutput.value = data.state()