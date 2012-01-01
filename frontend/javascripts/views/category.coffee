
class @Agora.views.Category extends @Agora.View

  events:
    'focus .post-title': 'showPreview',
  
  render: (params) ->
    self = @
    context = @context
    context.slug = params.slug

    context.storage.get (db) ->
      category = db.Category(slug: context.slug).first()
      context.partial('templates/category.template', { category: category }).then ->
        $threads = $ '.threads'
        render = self.getRenderer(
          category.threads,
          'thread-summary',
          (record) ->
            thread = db.Thread(_id: record).first()
            console.log "Thread", thread
            firstPost = db.Post(_id: thread.posts[0]).first()
            lastPost = db.Post(_id: thread.posts[thread.posts.length - 1]).first()
            user = db.User(_id: firstPost.user).first()
            lastUser = db.User(_id: lastPost.user).first()

            {
              category: category,
              thread: thread,
              user: user,
              lastUser: lastUser,
              lastUpdate: Agora.utils.formatDate lastPost.date,
            }
          (node) -> $threads.append node,
          (->
            context.render('templates/new-thread.template', { category: category, user: context.user  }).then (node) ->
              $threads.append node
              self.bind()
          ),
        )
        render()

  showPreview: (event) ->
    $('.new-post').slideDown()
