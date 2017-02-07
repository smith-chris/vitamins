  module.exports = class Validator
    constructor: ({@elem, validate, @errorMessage, @successMessage, @warningMessage, action = "input"}) ->
      @valid = false
      @validate = => validate(@elem.value, @)
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

    error: (data) ->
      @valid = false
      console.log @errorMessage?(data)
      @trigger "error", data

    success: (@data) ->
      @valid = true
      console.log @successMessage?(@data)
      @trigger "success", @data

    warning: (data) ->
      console.log @warningMessage?(data)
      @trigger "warning", data