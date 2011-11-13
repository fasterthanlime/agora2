
class @Agora.views.Forum extends @Agora.View
  
  render: ->
    self = @
    context = @context
    context.partial('templates/home.template').then ->
      $categories = $ '.categories'
      context.storage.get (db) ->
        render = self.getRenderer(
          db.Category().order('_id desc').get(),
          'category-summary',
          (record) -> { category: record },
          (node) -> $categories.append node
        )
        render()
