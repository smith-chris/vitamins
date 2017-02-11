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

  removeClasses = ($element) ->
    for className in $element.classList
      $element.classList.remove(className)

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
    targetSvg = $svgs[num - 3]
    removeClasses(targetSvg)
    targetSvg.classList.add(color)

  animating = false
  interval = null
  animate = (operations) ->
    if operations?.length > 0
      i = 1
      animating = true
      visualize(operations[0].groups)
      interval = setInterval (->
        if i is operations.length
          stopAnimation()
          return
        visualize(operations[i++].groups)
      ), 750

  stopAnimation = ->
    clearInterval(interval)
    animating = false
    $animateButton.innerHTML = "Start animation"
    $animateButton.classList.remove("active")


  $initialState = $("#initial-state")
  $swapOperations = $("#swap-operations")
  $finalState = $("#final-state")

  $animateButton = $("#animate")

  $animateButton.addEventListener "click", ->
    if not animating
      if not this.classList.contains("disabled")
        $animateButton.innerHTML = "Stop animation"
        $animateButton.classList.add("active")
        animate swapOperationsValidation.data.branch()
    else
      stopAnimation()


  initialStateValidation = new Validator(
    elem: $initialState
    validate: (text) -> exerciseSolver.validateInput(text, @)
  )

  onFormError = () ->
    $animateButton.classList.add("disabled")
    
  onFormValidated = () ->
    $animateButton.classList.remove("disabled")

  initialStateValidation.on "success", (node) ->
    visualize(node.groups)
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