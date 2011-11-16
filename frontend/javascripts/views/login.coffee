
class @Agora.views.Login extends @Agora.View
  
  events: 
    'keypress #password' : 'submit'
  
  render: (data) ->
    @context.partial 'templates/login.template'
    
  submit: (event) ->
    return unless event.which == 13
    event.preventDefault()

    console.log 'Logging in with: ', @$el( '#username' ).val(), @$el( '#password' ).val()
    # TODO: Change this ASAP! SHA-1( password )
    context = @context
    self = @

    Agora.app.gateway.login $('#username').val(), $('#password').val(), {
      notify: (type, data) ->
        context.log('Received notification "' + type + '" with data', data)
        if(type == "onLogin")
          self.onLogin(data)
    }

  onLogin: (result) ->
    app = Agora.app
    app.remote = result.remote
    context = @context

    if (result.status != 'success')
      context.log 'Error while logging in: ' + result
    else
      context.session 'user', result.session.user
      context.session 'token', result.session.token
      context.redirect app.redirect_to

