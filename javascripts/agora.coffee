# Simple sammy test in CS :)

app = $.sammy '#main', ->
  @use 'Template'

  @get '#/', (context) ->
    context.app.swap ''
    context.$element().html "Booya"

  @get '#/category/:id/new', (context) ->
    @partial('templates/new-thread.template')

  @bind 'run', ->

$ -> app.run '#/'
