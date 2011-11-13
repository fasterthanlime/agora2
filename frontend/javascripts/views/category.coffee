
class @Agora.views.Category extends @Agora.View
  
  render: (params) ->
    self = @
    context = @context
    context.slug = params.slug

    context.storage.get 'categories', (Category) ->
      category = Category.query({ slug: context.slug }).first()
      context.partial('templates/category.template', { category: category }).then ->
        $threads = $ '.threads'
        context.storage.get 'threads', (Thread) ->
          render = self.getRenderer(
            category.threads,
            'thread-summary',
            (record) -> { category: category, thread: Thread.query({ _id: record }).first() }
            ,
            (node) -> $threads.append node,
          )
          render()

  bind: ->
    console.log "TODO: Category bind"
