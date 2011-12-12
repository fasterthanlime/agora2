
class @Agora.views.Profile extends @Agora.View
  
  render: (params) ->
    username = params.username
    context = @context
    context.storage.get (db) ->
      user = db.User({ username: username }).first()
      context.partial 'templates/profile.template', {
        user: user
        date: Agora.utils.formatDate(user.joindate)
      }
  