
@Agora.app = $.sammy '#main', ( app ) ->
  @use 'Template'
  @use 'Storage'
  @use 'Session'

  setupSession.apply @, [app]

  # Login box
  @get '#/login', (context) ->
    app.view = new Agora.views.Login(context)
    app.view.render().then -> app.view.bind()

  # List of categories
  @get '#/', (context) ->
    console.log Agora.views
    app.view = new Agora.views.Forum(context)
    app.view.render()

  # Thread list in a category
  @get '#/r/:slug', (context) ->
    app.view = new Agora.views.Category(context)
    app.view.render(@params)

  # Message list in a thread
  @get '#/r/:slug/:tid', (context) ->
    app.view = new Agora.views.Thread(context)
    app.view.render(@params)

  # Profile page
  @get '#/u/:username', (context) ->
    app.view = new Agora.views.Profile(context)
    app.view.render @params.username

  # Own profile page
  @get '#/u', (context) ->
    context.redirect '#/u/' + context.user.username

$ -> Agora.app.run '#/'
