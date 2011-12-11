
@Agora.app = $.sammy '#main', ( app ) ->
  @use 'Template'
  @use 'Storage'
  @use 'Session'

  setupSession.apply @, [app]

  load = (context, givenView) ->
    app.view = app.viewCache[context.path]
    if not app.view
      app.view = new givenView(context)
      app.viewCache[context.path] = app.view
      console.log "Just cached view for", context.path
    else
      console.log "Got view from cache for", context.path

  render = (context, givenView) ->
    load(context, givenView)
    app.view.render(context.params)

  # Login box
  @get '#/login', (context) ->
    render(context, Agora.views.Login)

  # List of categories
  @get '#/', (context) ->
    render(context, Agora.views.Forum)

  # Thread list in a category
  @get '#/r/:slug', (context) ->
    render(context, Agora.views.Category)

  # Message list in a thread
  @get '#/r/:slug/:tid', (context) ->
    render(context, Agora.views.Thread)

  # Profile page
  @get '#/u/:username', (context) ->
    render(context, Agora.views.Profile)

  # Own profile page
  @get '#/u', (context) ->
    context.redirect '#/u/' + context.user.username

$ -> Agora.app.run '#/'
