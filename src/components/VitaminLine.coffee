module.exports = class Vitamins
  constructor: ({@vitamins, @parent, @controlButton, @data}) ->
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

  scrollToView: (callback) ->
    targetY = @parent.offsetTop - 10
    if window.pageYOffset > targetY
      currentY = window.pageYOffset
      duration = 30
      step = (currentY - targetY) / duration
      @scrollInterval = setInterval (=>
        currentY -= step
        if currentY < targetY
          currentY = targetY
          clearInterval(@scrollInterval)
          callback()
        window.scrollTo(window.scrollX, currentY)
      ), 1
    else
      callback()

  animate: (operations) ->
    if !@animating
      if operations?.length > 0
        clearInterval(@scrollInterval)
        @scrollToView =>
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
    if @animating
      clearInterval(@interval)
      @animating = false
      @controlButton.innerHTML = "Start animation"
      @controlButton.classList.remove("active")