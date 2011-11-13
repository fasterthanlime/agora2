
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
    app = Agora.app
    context = @context

    app.gateway.login $('#username').val(), $('#password').val(), {
      onLogin: (result) ->
        app.remote = result.remote
        if (result.status != 'success')
          context.log 'Error while logging in: ' + result
        else
          context.session 'user', result.session.user
          context.session 'token', result.session.token
          context.redirect app.redirect_to
      onPost: (post) ->
        alert JSON.stringify(post)
    }

