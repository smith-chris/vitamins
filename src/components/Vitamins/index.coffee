require "./styles.sass"

module.exports = class Vitamins
  constructor: ({@controlButton, @data, @minVitamin, @maxVitamin}) ->
    @animating = false
    @interval = null
    @view = document.createElement("span")
    @view.classList.add("vitamins")
    @vitamins = []

    if not @controlButton
      @controlButton = document.createElement("div")
      @controlButton.classList.add("button")

    @controlButton.innerHTML = "Start animation"
    @controlButton.addEventListener "click", =>
      if not @animating
        if not @controlButton.classList.contains("disabled")
          @controlButton.innerHTML = "Stop animation"
          @controlButton.classList.add("active")
          @animate @data()
      else
       @stopAnimation()
    if @minVitamin < 3
      @minVitamin = 3
      console.warn "new Vitamins(minVitamin: num) - num cannot be lower then 3."
    for i in [@minVitamin..@maxVitamin]
      vitamin = @generateVitamin(
        sides: i,
        size: 100
      )
      vitaminWrapper = document.createElement("span")
      vitaminWrapper.appendChild(vitamin)
      vitaminNumber = document.createElement("span")
      vitaminNumber.classList.add("vitamin-number")
      vitaminNumber.innerHTML = i
      vitaminWrapper.appendChild(vitaminNumber)
      @vitamins.push vitaminWrapper
      @view.appendChild vitaminWrapper

  generateVitamin: ({sides, size})->
    xmlns = "http://www.w3.org/2000/svg";
    radius = size / 2 - 1
    if sides % 4 is 0
      theta = (1/sides) * Math.PI
    else if sides % 2 isnt 0
      theta = -0.5 * Math.PI
    else
      theta = 0
    i = 1
    points = ""
    yOffset = 0
    switch sides
      when 3
        yOffset = 0.25 * radius + 1
      when 5, 7
        yOffset = 0.05 * radius + 1
      when 9
        yOffset = 0.03 * radius + 1

    while i <= sides
      x = radius * Math.cos(2 * Math.PI * i / sides + theta) + size/2
      y = radius * Math.sin(2 * Math.PI * i / sides + theta) + size/2 + yOffset
      points += "#{parseInt(x)},#{parseInt(y)} "
      i++

    svg = document.createElementNS(xmlns, "svg")
    polygon = document.createElementNS(xmlns, "polygon")
    polygon.setAttribute("points", points)
    svg.appendChild(polygon)
    return svg

  removeClasses: ($element) ->
    for className in $element.classList
      $element.classList.remove(className)

  resetVitamins: () ->
    for e in @vitamins
      @removeClasses(e)

  visualize: (groups) ->
    @resetVitamins()
    for key, val of groups
      for num in val
        @applyColor(num, key)

  applyColor: (num, color) ->
    targetVitamin = @vitamins[num - 3]
    @removeClasses(targetVitamin)
    targetVitamin.classList.add(color)

  scrollToView: (callback) ->
    targetY = @view.offsetTop - 10
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

  animate: (nodesBranch) ->
    if !@animating
      if nodesBranch?.length > 0
        clearInterval(@scrollInterval)
        @scrollToView =>
          i = 1
          @animating = true
          @visualize(nodesBranch[0].groups)
          @interval = setInterval (=>
            if i is nodesBranch.length
              @stopAnimation()
              return
            @visualize(nodesBranch[i++].groups)
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