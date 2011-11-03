# Simple sammy test in CS :)

app = $.sammy '#main', ->
  @use 'Template'

  @get '#/', (context) ->
    context.app.swap ''
    context.$element().html "Booya"

  @bind 'run', ->

$ -> app.run '#/'
