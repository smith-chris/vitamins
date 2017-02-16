Validator = require "./Validator"

module.exports = class Form
  constructor: ({fields, @submit, groups})->
    @fields = {}
    @required = []
    @requiredGroups = {}
    @listeners = {}
    for group in groups
      @requiredGroups[group.name] = {
        requiredFields: group.requiredFields
        fields: []
      }

    for field in fields
      field.form = @
      @fields[field.name] = new Validator(field)

      if field.required is true
        @required.push @fields[field.name]

      else if field.required
        if field.required.group
          groupName = field.required.group
          @requiredGroups[groupName].fields.push @fields[field.name]

      @fields[field.name].on "valid", @validate

    for field in fields
      if Array.isArray(field.prerequisites)
        for prerequisite in field.prerequisites
          @fields[prerequisite].addPostrequisite(@fields[field.name])
          @fields[field.name].addPrerequisite(@fields[prerequisite])

    if @submit?
      @submit.addEventListener "click", @validate.bind(@, true)

      @on "success", -> @submit.classList.remove "disabled"

      @on "error", -> @submit.classList.add "disabled"


  on: (eventName, callback) ->
    if callback and typeof callback is "function"
      if not @listeners[eventName]
        @listeners[eventName] = []
      @listeners[eventName].push callback.bind(@)

  trigger: (eventName, data) ->
    if @listeners[eventName]
      for listener in @listeners[eventName]
        listener(data)

  validate: (force = false) =>
    valid = true
    if @required
      for field in @required
        if not field.valid
          if force is true
            field.validate(force: true)
            return

          valid = false

    for groupName, group of @requiredGroups
      requiredFieldsAmount = group.requiredFields
      validFields = 0
      for field in group.fields
        if field.valid
          validFields++

      if validFields < requiredFieldsAmount
        valid = false
        if force is true
          for field in group.fields
            if not field.valid
              field.validate(force: true)
              return

    if valid
      @trigger "success"
    else
      @trigger "error"