# Simple sammy test in CS :)

showdown = new Showdown.converter()

@Agora = 
  app: null,
  views: {},
  database: {}

@Agora.app = $.sammy '#main', ( app ) ->
  
  @use 'Eco'
  @use 'Storage'
  @use 'Session'
  
  # At application start
  @bind 'run', ->
    console.log 'run'
    Agora.template = @eco.bind( @ )
  
  # Before routing
  @before (ctx) ->
    console.log 'before'
    if ctx.path != '#/login'
      @redirect '#/login'
  
  # Login box
  @get '#/login', (ctx) ->
    console.log 'GET #/login'
    view = new Agora.views.Login(ctx)
    view.render()
    view.bind()
  
  # Category list
  @get '#/', (ctx) ->
    console.log 'GET #/'

