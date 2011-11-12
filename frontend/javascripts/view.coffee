
@Agora.View = class View
  
  events: {}
  
  constructor: (@context) ->
    @$el = @context.$element.bind(@context)
  
  bind: ->
    for binding, callback of @events
      [event, selector] = binding.split ' '
      console.log "Binding #{event} with #{selector}."
      @$el(selector).on( event, @[ callback ].bind( @ ) )
    @

  getRenderer: (records, template, prepare, insert) ->
    context = @context
    render = (index = 0) ->
      if index < records.length
        record = records[records.length - 1 - index]
        data = prepare record
        context.render('templates/' + template + '.template', data ).then (node) ->
          insert node
          render index + 1
