
@Agora.app = $.sammy '#main', ( app ) ->
  @use 'Template'
  @use 'Storage'
  @use 'Session'

  setupSession.apply @, [app]

  # Login box
  @get '#/login', (context) ->
    view = new Agora.views.Login(context)
    view.render().then -> view.bind()

  # List of categories
  @get '#/', (context) ->
    console.log Agora.views
    view = new Agora.views.Forum(context)
    view.render()

  # Thread list in a category
  @get '#/r/:slug', (context) ->
    view = new Agora.views.Category(context)
    view.render(@params)

  # Message list in a thread
  @get '#/r/:slug/:tid', (context) ->
    view = new Agora.views.Thread(context)
    view.render(@params)

  # Profile page
  @get '#/u/:username', (context) ->
    view = new Agora.views.Profile(context)
    view.render @params.username

  # Own profile page
  @get '#/u', (context) ->
    context.redirect '#/u/' + context.user.username

$ -> Agora.app.run '#/'
