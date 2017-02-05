Node = require "Node"
NodeWalker = require "NodeWalker"

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
  console.log exerciseSolver.getStates("3g 4g", [
    [4, "G", "B"],
    [3, "G", "W"],
    [4, "B", "W"]
  ])

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

  $vitaminInput.addEventListener("keyup", ->
    visualize exerciseSolver.makeGroups(this.value)
  )