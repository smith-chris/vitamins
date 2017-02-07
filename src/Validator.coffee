  module.exports = class Validator
    constructor: ({@elem, validate, action = "input"}) ->
      @valid = false
      @validate = => validate.call(@, @elem.value)
      @listeners = {}
      @elem.addEventListener(action, @validate)
      @messageElem = @elem.parentNode.querySelector(".input-msg")

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
      @messageElem.innerHTML = message
      @trigger "error", data

    success: (@data, message) ->
      @valid = true
      @messageElem.innerHTML = message || ""
      @trigger "success", @data

    warning: (data, message) ->
      @messageElem.innerHTML = message
      @trigger "warning", data