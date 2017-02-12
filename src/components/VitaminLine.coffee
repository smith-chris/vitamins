module.exports = class Vitamins
  constructor: ({@vitamins, @controlButton, @data}) ->
    @animating = false
    @interval = null

    @controlButton.innerHTML = "Start animation"
    @controlButton.addEventListener "click", =>
      if not @animating
        if not @controlButton.classList.contains("disabled")
          @controlButton.innerHTML = "Stop animation"
          @controlButton.classList.add("active")
          @.animate @data()
      else
       @stopAnimation()

  removeClasses: ($element) ->
    for className in $element.classList
      $element.classList.remove(className)

  resetSvgs: () ->
    for e in @vitamins
      @removeClasses(e)

  visualize: (groups) ->
    @resetSvgs()
    for key, val of groups
      for num in val
        @applyColor(num, key)

  applyColor: (num, color) ->
    targetSvg = @vitamins[num - 3]
    @removeClasses(targetSvg)
    targetSvg.classList.add(color)

  animate: (operations) ->
    if !@animating
      if operations?.length > 0
        i = 1
        @animating = true
        @visualize(operations[0].groups)
        @interval = setInterval (=>
          if i is operations.length
            @stopAnimation()
            return
          @visualize(operations[i++].groups)
        ), 750
        return true
    return false

  enable: ->
    @controlButton.classList.remove("disabled")

  disable: ->
    @controlButton.classList.add("disabled")

  stopAnimation: ->
    clearInterval(@interval)
    @animating = false
    @controlButton.innerHTML = "Start animation"
    @controlButton.classList.remove("active")