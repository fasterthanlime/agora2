
class @Agora.views.Thread extends @Agora.View
  
  render: (params) ->
    self = @
    context = @context

    tid = params.tid

    context.storage.get 'threads', (Thread) ->
      thread = Thread.query({ _id: tid }).first()
      context.storage.get 'categories', (Category) ->
        category = Category.query({ _id: thread.category }).first() 
        posts = thread.posts
        context.partial('templates/thread.template', { category: category, thread: thread }).then ->
          context.storage.get 'posts', (Post) ->
            context.storage.get 'users', (User) ->
              $thread = $ '.thread'
              render = self.getRenderer(
                posts,
                'post',
                (record) ->
                  post = Post.query({ _id: record }).first()
                  content = Agora.utils.md2html post.source
                  post: {
                    content: content
                    date: Agora.utils.formatDate post.date
                    user: User.query({ _id: post.user }).first()
                  }
                ,
                (node) -> $thread.append node 
              )
              render()

  bind: ->
    console.log "TODO: Thread bind"
