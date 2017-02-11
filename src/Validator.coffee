module.exports = class Validator
  constructor: ({@elem, validate, action = "input"}) ->
    @valid = false
    @validate = => validate.call(@, @elem.value)
    @listeners = {}
    @elem.addEventListener(action, @validate)
    @messageElem = @elem.parentNode.querySelector(".input-msg")

  clear: ->
    @messageElem.classList.remove("error", "warning")
    @messageElem.innerHTML = ""

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
    # TODO show messages after ~.5s delay to not interrupt user unnecessary
    @valid = false
    @messageElem.innerHTML = message
    @messageElem.classList.add("error")
    @trigger "error", data

  success: (@data) ->
    @valid = true
    @clear()
    @trigger "success", @data

  warning: (data, message) ->
    @messageElem.innerHTML = message
    @messageElem.classList.add("warning")
    @trigger "warning", data