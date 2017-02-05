document.addEventListener "DOMContentLoaded", ->

  $ = document.querySelector.bind(document)

  NodeWalker = require "NodeWalker"

  possibleGroups = "gwb"

  exerciseSolver = new NodeWalker(possibleGroups)

  # Exercise 1B
  console.log exerciseSolver.makeAllWhite("3g 4g")

  # Exercise 3A
  console.log exerciseSolver.getStates("3g 4g", [
    [4, "G", "B"],
    [3, "G", "W"],
    [4, "B", "W"]
  ])

  $vitaminInput = $("#vitamin-input")
  $vitaminInput.addEventListener("keyup", ->
    console.log this.value
  )