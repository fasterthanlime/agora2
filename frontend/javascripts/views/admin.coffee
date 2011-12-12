
class @Agora.views.Admin extends @Agora.View
  
  render: ->
    self = @
    context = @context
    $admin = $ '.admin'
    
    db.User.find({}, (err, users) ->
      users.forEach (user) ->
        $admin.append('Utilisateur ' + user.nickname)
    )
    context.partial('templates/admin.template'), {}
  
