Validator = require "Validator"
NodeWalker = require "NodeWalker"

module.exports = ({$makeAllWhiteBtn, $initialState,
$swapOperations, $finalState, exerciseSolver, vitamins, onFormError, onFormValidated}) ->
  res = {}
  $makeAllWhiteBtn.addEventListener "click", ->
    if not @classList.contains("disabled")
      $finalState.value = NodeWalker.stateToWhite res.initialStateValidation.data.state()
      finalStateValidation.validate(true)

  res.initialStateValidation = new Validator(
    elem: $initialState
    validate: (text) -> exerciseSolver.validateInput(text, @)
  )

  res.initialStateValidation.on "success", (node) ->
    vitamins.visualize(node.groups)
    vitamins.stopAnimation()
    $makeAllWhiteBtn.classList.remove "disabled"
    res.swapOperationsValidation.validate()
    if res.swapOperationsValidation.valid
      onFormValidated()
    else
      finalStateValidation.validate()
      if finalStateValidation.valid
        onFormValidated()

  res.initialStateValidation.on "error", (data) ->
    $makeAllWhiteBtn.classList.add "disabled"
    onFormError()
    if !data or data is ""
      vitamins.resetSvgs()


  res.swapOperationsValidation = new Validator(
    elem: $swapOperations
    validate: (text) ->
      if res.initialStateValidation.valid
        exerciseSolver.validateOperations(operations: text, validate: @, node: res.initialStateValidation.data)
      else
        @error(res.initialStateValidation.data, "You must pass correct value to the initial field to proceed.")
  )

  res.swapOperationsValidation.on "error", onFormError

  res.swapOperationsValidation.on "success", (data) ->
    if data isnt res.initialStateValidation.data
      $finalState.value = data.state()
      finalStateValidation.clearMessage()
      onFormValidated()


  finalStateValidation = new Validator(
    elem: $finalState
    validate: (text) ->
      if res.initialStateValidation.valid
        exerciseSolver.validateInput(text, @)
      else
        @error(res.initialStateValidation.data, "You must pass correct value to the initial field to proceed.")
  )

  finalStateValidation.on "error", onFormError

  # TODO final success
  finalStateValidation.on "success", (data) ->
    startNode = res.initialStateValidation.data
    endNode = data
    exerciseSolver.validateIsPossibleToFind(
      startNode: startNode
      endNode: endNode
      validate:
        error: @error.bind(@)
        success: =>
          endNode = exerciseSolver.find(startNode.state(), endNode.state())
          if endNode
            onFormValidated()
            $swapOperations.value = endNode?.swaps()
            res.swapOperationsValidation.clearMessage()
            res.swapOperationsValidation.data = endNode
    )


  $initialState.value = "3g 4g"
  res.initialStateValidation.validate(true)
  return res