
@Agora.View = class View
  
  events: {}
  
  constructor: (@context) ->
    @$el = @context.$element.bind(@context)
    @app = Agora.app
  
  bind: ->
    for binding, callback of @events
      [event, selector] = binding.split ' '
      console.log "Binding #{event} with #{selector}."
      @$el(selector).on( event, @[ callback ].bind( @ ) )
    if not @bound
      @bound = true
      for index, event of @appEvents
        console.log "Binding appevent #{event}"
        self = @
        @app.bind(event, (context, data) -> self[ event ].call(self, data))
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
