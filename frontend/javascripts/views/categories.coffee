
class @Agora.views.Categories extends @Agora.View
  
  render: ->
    self = @
    context = @context
    context.partial('templates/home.template').then ->
      $categories = $ '.categories'
      context.storage.get 'categories', (Category) ->
        render = self.getRenderer(
          Category.query().get(),
          'category-summary',
          (record) -> { category: record },
          (node) -> $categories.append node
        )
        render()
