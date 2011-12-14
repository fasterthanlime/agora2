
@Agora.View = class View
  
  events: {}
  
  constructor: (@context) ->
    @$el = @context.$element.bind(@context)
    @app = Agora.app
  
  bind: ->
    self = @
    for binding, callback of @events
      [event, selector] = binding.split ' '
      console.log "Binding #{event} with #{selector}."
      @$el(selector).on( event, @[ callback ].bind( @ ) )
    if not @bound
      @bound = true
      for index, event of @appEvents
        doStuff = (() ->
          method = self[event]
          console.log "Binding appevent #{event} to method #{method}"
          self.app.bind(event, (context, data) ->
            console.log "Calling method #{event} with #{data}"
            method.call(self, data)
          )
        )
        doStuff()
    @

  getRenderer: (records, template, prepare, insert, finish) ->
    context = @context
    render = (index = 0) ->
      if index < records.length
        record = records[records.length - 1 - index]
        data = prepare record
        context.render('templates/' + template + '.template', data ).then (node) ->
          insert node
          render index + 1
      else
        finish() unless !finish
