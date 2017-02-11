module.exports = class Validator
  constructor: ({@elem, validate, action = "input"}) ->
    @valid = false
    @validate = => validate.call(@, @elem.value)
    @listeners = {}
    @elem.addEventListener(action, @validate)
    @messageElem = @elem.parentNode.querySelector(".message")
    @textElem = @messageElem.appendChild(document.createElement("div"))

  clearMessage: ->
    @messageElem.style.height = 0
    @elem.parentNode.classList.remove("error", "warning")
    clearTimeout(@messageTimeout)
    @messageTimeout = setTimeout (=>
      @textElem.innerHTML = ""
    ), 500

  showMessage: (messageType, messageText) ->
    clearTimeout(@messageTimeout)
    @textElem.classList.remove("error", "warning")
    @textElem.classList.add(messageType)
    @textElem.innerHTML = messageText
    @messageElem.style.height = "#{@textElem.offsetHeight}px"
    @elem.parentNode.classList.add(messageType)

  on: (eventName, callback) ->
    if callback and typeof callback is "function"
      if not @listeners[eventName]
        @listeners[eventName] = []
      @listeners[eventName].push callback.bind(@)

  trigger: (eventName, data) ->
    if @listeners[eventName]
      for listener in @listeners[eventName]
        listener(data)

  error: (data, message) ->
    @valid = false
    @showMessage("error", message)
    @trigger "error", data

  success: (@data) ->
    @valid = true
    @clearMessage()
    @trigger "success", @data

  warning: (data, message) ->
    @showMessage("warning", message)
    @trigger "warning", data