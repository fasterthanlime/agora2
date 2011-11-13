
class @Agora.views.Thread extends @Agora.View
  
  render: (params) ->
    self = @
    context = @context

    tid = params.tid

    context.storage.get (db) ->
      thread = db.Thread({ _id: tid }).first()
      category = db.Category({ _id: thread.category }).first() 
      posts = thread.posts
      context.partial('templates/thread.template', { category: category, thread: thread }).then ->
        $thread = $ '.thread'
        render = self.getRenderer(
          posts,
          'post',
          (record) ->
            post = db.Post({ _id: record }).first()
            content = Agora.utils.md2html post.source
            post: {
              content: content
              date: Agora.utils.formatDate post.date
              user: db.User({ _id: post.user }).first()
            }
          ,
          (node) -> $thread.append node 
        )
        render()

  bind: ->
    console.log "TODO: Thread bind"
