Node = require "Node"
NodeWalker = require "NodeWalker"
VitaminLine = require "components/VitaminLine"
Validator = require "Validator"
Form2 = require("Form2")
require "styles"

document.addEventListener "DOMContentLoaded", ->
  $ = document.querySelector.bind(document)
  $$ = document.querySelectorAll.bind(document)

  vitamins = new VitaminLine(
    vitamins: $$(".shapes svg")
    parent: $(".shapes")
    controlButton: $("#animate")
    data: -> form1.swapOperationsValidation.data.branch()
  )

  exerciseSolver = new NodeWalker(
    possibleGroups: "gwb"
    filter: (num) -> num > 2 and num < 7
  )

  form1 = require("Form")(
    $initialState: $("#initial-state")
    $swapOperations: $("#swap-operations")
    $finalState: $("#final-state")
    $makeAllWhiteBtn: $("#make-all-white")
    exerciseSolver: exerciseSolver
    vitamins: vitamins
    onFormError: -> vitamins.disable()
    onFormValidated: -> vitamins.enable()
  )

  form = new Form2(
    fields: [
      {
        elem: $("#initial-state")
        validate: (text) -> exerciseSolver.validateInput(text, @)
        name: "initialState"
        required: true
        # on success - validate what depends on it
        # and trigger formValidated if valid
      }
      {
        elem: $("#swap-operations")
        validate: (text, dependantData) -> exerciseSolver.validateOperations(
          operations: text,
          validate: @,
          node: dependantData
        )
        onSuccess: (data) ->
          if @get("initialState").data isnt data
            @get("finalState").fill(data.state())
        dependsOn: ["initialState"]
        required:
          oneInGroup: "forAnimation"
      }
      {
        elem: $("#make-all-white")
        validate: (text) -> exerciseSolver.validateInput(text, @)
        name: "finalState"
        # will automatically check if this field is valid before proceeding
        dependsOn: ["initialState"]
        required:
          oneInGroup: "forAnimation"
      }
    ]
    onFieldsValidated: ->
      # if onFieldsValidated is provided, it will be triggered
      # before onFormValidated
      startNode = @get("initialState").data
      endNode = @get("finalState").data
      exerciseSolver.validateIsPossibleToFind(
        startNode: startNode
        endNode: endNode
        validate:
          error: @get("finalState").error.bind(@)
          success: =>
            endNode = exerciseSolver.find(startNode.state(), endNode.state())
            if endNode
              tr
              $swapOperations.value = endNode?.swaps()
              res.swapOperationsValidation.clearMessage()
              res.swapOperationsValidation.data = endNode
      )
    # adds click event that will validate whole form
    submit: $("#animate")
  )

  # questionable api
  form.get("initialState").onChange "valid", (value) ->
    $("#make-all-white").classList[value?"remove":"add"]("disabled")

  form.get("initialState").on "success", (data) ->
    vitamins.visualize(node.groups)
    vitamins.stopAnimation()

  # any field error will trigger formError also
  form.get("initialState").on "error", (data) ->
    if !data or data is ""
      vitamins.resetSvgs()

  $("#make-all-white").addEventListener "click", ->
    # form.valid() returns if form is valid
    # with value returns if field is valid
    if form.get("initialState").valid
      initialState = form.getFieldData("initial state")
      # todo hook auto validation on setting value
      form.get("final state").fill(NodeWalker.stateToWhite(initialState))


