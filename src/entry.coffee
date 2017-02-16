Node = require "utils/Node"
NodeWalker = require "utils/NodeWalker"
Vitamins = require "components/Vitamins"
Validator = require "components/Validator"
Form = require "components/Form"
require "styles"

document.addEventListener "DOMContentLoaded", ->
  $ = document.querySelector.bind(document)

  $form = $(".form")

  minVitamin = 3
  maxVitamin = 7

  exerciseSolver = new NodeWalker(
    possibleGroups: "gwb"
    filter: (num) -> num >= minVitamin and num <= maxVitamin
  )

  form = new Form(
    fields: [
      {
        elem: $("#initial-state")
        validate: (text) -> exerciseSolver.validateState(text)
        name: "initialState"
        required: true
      }
      {
        elem: $("#swap-operations")
        validate: (text) ->
          exerciseSolver.validateOperations(
            operations: text,
            node: @form.fields.initialState.data
          )
        name: "swapOperations"
        on:
          setData: ({data}) -> @fill(data.swaps(), false)
          success: ({data}) -> @form.fields.finalState.setData(data)
        prerequisites: ["initialState"]
        required:
          group: "forAnimation"
      }
      {
        elem: $("#final-state")
        validate: (text) ->
          result = exerciseSolver.validateState(text)
          if result.type isnt "error"
            if result.data
              return exerciseSolver.validateIsPossibleToFind
                initialNode: @form.fields.initialState.data
                finalNode: result.data
          return result
        on:
          setData: ({data}) -> @fill(data.state(), false)
          success: ({data}) -> @form.fields.swapOperations.setData(
            exerciseSolver.find(
              data.initialNode.state(),
              data.finalNode.state()
            )
          )
        name: "finalState"
        # will automatically check if this field is valid before proceeding
        prerequisites: ["initialState"]
        required:
          group: "forAnimation"
      }
    ]
    groups: [
      {
        name: "forAnimation"
        requiredFields: 1
      }
    ]
    # adds click event that will validate whole form
    submit: $("#animate")
  )

  form.fields.initialState.on "valid", ({data}) ->
    $("#make-all-white").classList[if data then "remove" else "add"]("disabled")

  $("#make-all-white").addEventListener "click", ->
    if form.fields.initialState.valid
      initialStateText = form.fields.initialState.data.state()
      form.fields.finalState.fill(NodeWalker.stateToWhite(initialStateText))

  vitamins = new Vitamins(
    controlButton: $("#animate")
    minVitamin: minVitamin
    maxVitamin: maxVitamin
    data: -> form.fields.swapOperations.data.branch()
  )

  $form.insertBefore(vitamins.view, $form.querySelector(".input-group"))

  form.fields.initialState.on "success", ({data}) ->
    vitamins.visualize(data.groups)
    vitamins.stopAnimation()

  form.fields.initialState.on "error", -> vitamins.resetVitamins()