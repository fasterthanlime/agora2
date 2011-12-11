
class @Agora.views.Login extends @Agora.View
  
  events: 
    'keypress #password' : 'submit'

  appEvents: [ 'onLogin' ]
  
  render: (data) ->
    self = @
    @context.partial('templates/login.template').then ->
      self.bind()
    
  submit: (event) ->
    return unless event.which == 13
    event.preventDefault()

    console.log 'Logging in with: ', @$el( '#username' ).val(), @$el( '#password' ).val()
    # TODO: Change this ASAP! SHA-1( password )
    @app.gateway.login $('#username').val(), $('#password').val(), { notify: @app.notify }

  onLogin: (result) ->
    if (result.status != 'success')
      @context.log 'Error while logging in: ', result
      $('#login-status').text(result.reason)
    else
      @app.remote = result.remote
      @context.session 'user', result.session.user
      @context.session 'token', result.session.token
      @context.redirect @app.redirect_to


