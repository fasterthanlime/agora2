
class @Agora.views.Admin extends @Agora.View
  
  render: (params) ->
    username = params.username
    context = @context
    context.storage.get (db) ->
      user = db.User({ username: username }).first()
      context.partial 'templates/admin.template', {
        user: user
        date: Agora.utils.formatDate(user.joindate)
      }
  
