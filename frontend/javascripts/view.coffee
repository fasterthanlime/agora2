
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