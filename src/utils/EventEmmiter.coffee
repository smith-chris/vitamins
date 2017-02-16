module.exports = class EventEmmiter
  on: (eventName, callback) ->
    if callback and typeof callback is "function"
      if not @listeners[eventName]
        @listeners[eventName] = []
      @listeners[eventName].push callback.bind(@)

  emit: (eventName, data) ->
    if @listeners[eventName]
      for listener in @listeners[eventName]
        listener(data)