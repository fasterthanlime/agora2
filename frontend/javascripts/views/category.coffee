
class @Agora.views.Category extends @Agora.View
  
  render: (params) ->
    self = @
    context = @context
    context.slug = params.slug

    context.storage.get (db) ->
      category = db.Category({ slug: context.slug }).first()
      context.partial('templates/category.template', { category: category }).then ->
        $threads = $ '.threads'
        render = self.getRenderer(
          category.threads,
          'thread-summary',
          (record) -> { category: category, thread: db.Thread({ _id: record }).first() }
          ,
          (node) -> $threads.append node,
        )
        render()

  bind: ->
    console.log "TODO: Category bind"
