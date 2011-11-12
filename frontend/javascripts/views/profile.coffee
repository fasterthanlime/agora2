
class @Agora.views.Profile extends @Agora.View
  
  render: (username) ->
    context = @context
    context.storage.get 'users', (User) ->
      user = User.query({ username: username }).first()
      context.partial 'templates/profile.template', {
        user: user
        date: Agora.utils.formatDate(user.joindate)
      }
  
