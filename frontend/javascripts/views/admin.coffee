
class @Agora.views.Admin extends @Agora.View
  
  render: ->
    self = @
    context = @context
    
    context.storage.get (db) ->
      context.partial('templates/admin.template').then ->
        $admin = $ '.admin'
        db.User().each (user) ->
          console.log 'Got user ' + user.nickname
          node = $('<p>Utilisateur ' + user.nickname + '</p>')
          $admin.append node
  
