
class @Agora.views.Admin extends @Agora.View
  
  render: ->
    self = @
    context = @context
    context.partial('templates/admin.template')
  
