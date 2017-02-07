  module.exports = class Validator
    constructor: ({@elem, validate, action = "input"}) ->
      @valid = false
      @validate = => validate.call(@, @elem.value)
      @listeners = {}
      @elem.addEventListener(action, @validate)

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
      console.log message
      # TODO show error message
      @trigger "error", data

    success: (@data, message) ->
      @valid = true
      @trigger "success", @data

    warning: (data, message) ->
      console.log message
      # TODO show warning message
      @trigger "warning", data