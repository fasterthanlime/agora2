
class @Agora.views.Login extends @Agora.View
  
  events: 
    'keypress #password' : 'submit'
  
  render: (data) ->
    html = @context.eco 'login', data
    @$el().html( html )
    
  submit: (event) ->
    return unless event.which == 13
    event.preventDefault()
    console.log 'Logging in with: ', @$el( '#username' ).val(), @$el( '#password' ).val()
  
  