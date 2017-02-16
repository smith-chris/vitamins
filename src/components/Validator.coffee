module.exports = class Validator
  constructor: ({@elem, @name, @form, validate, actionType = "input"}) ->
    @valid = false
    @wasFocused = false
    @listeners = {}
    @_validate = validate
    @elem.addEventListener(actionType, @validate)
    @elem.addEventListener("blur", @validate)
    @elem.addEventListener("focus", =>
      @wasFocused = true
      @elem.removeEventListener("focus", arguments.callee)
    )
    @messageElem = @elem.parentNode.querySelector(".message")
    @messageTextElem = @messageElem.appendChild(document.createElement("div"))

    @on "valid", ({data}) ->
      @valid = data

    @on "error", ({message}) ->
      @showMessage("error", message)
      @trigger "valid", data: false

    @on "success", ({@data}) ->
      @clearMessage()
      @trigger "valid", data: true

    @on "warning", ({data, message, passing = true}) ->
      if passing
        @trigger "success", data: data
      @showMessage("warning", message)

    if arguments[0].on
      for key, value of arguments[0].on
        @on key, value


  validate: ({force = false, forceRequisites = false, validateRequisites = true} = {}) =>
    if force
      @wasFocused = true
    if !validateRequisites or @prerequisitesValid()
      if @wasFocused
        validationResult = @_validate.call(@, @elem.value)
        @trigger validationResult.type, validationResult
        if @valid
          if validateRequisites or forceRequisites
            if @postrequisites
              for field in @postrequisites
                field.validate(
                  validateRequisites: false
                  force: forceRequisites
                  caller: @name
                )

  fill: (value, validate = true) ->
    @elem.value = value
    if validate
      @validate(force: true)

  setData: (data) ->
    @data = data
    @clearMessage()
    @trigger "setData", data: data

  decamelize: (text) ->
    while match = text.match /[A-Z]/
      text = text.replace match[0], " " + match[0].toLowerCase()
    text = text.trim()
    return text[0].toUpperCase() + text[1..]

  prerequisitesValid: ->
    if !@prerequisites or @prerequisites.length is 0
      return true
    else
      for field in @prerequisites
        if not field.valid
          @showMessage("error", "You must pass correct value to the '#{@decamelize(field.name)}' field to proceed.")
          return false
      return true

  addPostrequisite: (field) ->
    if not @postrequisites
      @postrequisites = []
    if field not in @postrequisites
      @postrequisites.push field

  addPrerequisite: (field) ->
    if not @prerequisites
      @prerequisites = []
    if field not in @prerequisites
      @prerequisites.push field

  clearMessage: ->
    @messageElem.style.height = 0
    @elem.parentNode.classList.remove("error", "warning")
    clearTimeout(@messageTimeout)
    @messageTimeout = setTimeout (=>
      @messageTextElem.innerHTML = ""
    ), 500

  showMessage: (messageType, messageText) ->
    clearTimeout(@messageTimeout)
    @messageTextElem.classList.remove "error", "warning"
    @messageTextElem.classList.add messageType
    @messageTextElem.innerHTML = messageText
    @messageElem.style.height = "#{@messageTextElem.offsetHeight}px"
    @elem.parentNode.classList.remove "error", "warning"
    @elem.parentNode.classList.add messageType

  on: (eventName, callback) ->
    if callback and typeof callback is "function"
      if not @listeners[eventName]
        @listeners[eventName] = []
      @listeners[eventName].push callback.bind(@)

  trigger: (eventName, data) ->
    if @listeners[eventName]
      for listener in @listeners[eventName]
        listener(data)