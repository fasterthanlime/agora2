@Agora = { app: null, views: {} }

@setupSession = (app) ->
  
  app.storage = null
  app.gateway = null
  app.remote = null
  app.redirect_to = '#/' # by default, to avoid redirecting to undefined..

  @before (context) ->
    @remote = app.remote
    @storage = app.storage
    @user = @session 'user'

    if context.path != '#/login'
      if !@remote && context.path != '#/resume'
        app.redirect_to = context.path
        context.log 'Resuming, will redirect to ' + app.redirect_to + ' when done.'
        context.redirect '#/resume'
      if !@user
        $('.user-info').fadeOut()
        @redirect('#/login')
        return false
      if !@storage
        @storage = new Agora.Storage(@session, @remote)
        app.storage = @storage
      $('.nickname').text(@user.nickname)
      $('.avatar').attr('src', @user.avatar)
      $('.user-info').fadeIn()

  @bind 'run', ->
    context = @
    @trigger 'before-dnode-connect'
    DNode.connect (gateway) ->
      app.gateway = gateway
      context.trigger 'after-dnode-connect'

  @bind 'before-dnode-connect', ->
    context = @
    context.log 'Connecting to dnode'
    @$element().hide()
    
  @bind 'after-dnode-connect', (context) ->
    context = @
    context.log 'Just connected via dnode'
    if @session('token')
      app.gateway.resume @session('token'), (result) ->
        if result.status == 'success'
          app.remote = result.remote
          context.log 'Resumed!, can now go back to ' + app.redirect_to
          context.redirect app.redirect_to
        else
          context.log 'Could not resume session, forced log off'
          $('.user-info').fadeOut()
          context.session('token', null)
          context.session('user', null)
          context.redirect '#/login'
    @$element().fadeIn()

  @get '#/resume', (context) ->
    context.log 'So, resume huh?'

  @get '#/logout', (context) ->
    $('.user-info').fadeOut()
    @remote 'logout', ->
      context.log 'Logged out gracefully!'
      # Note that if we don't, it's no biggie. Token
      # will end up expiring anyways.
    @session('user', null)
    @session('token', null)
    # Couldn't find a good way to clear, nulling works just as fine
    @redirect('#/login')

