
class @Agora.views.Thread extends @Agora.View
  
  events:
    'click .submit-post' : 'submit',
    'blur .post-source' : 'showPreview',
    'click .post-preview' : 'hidePreview',

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
          ->
            context.render('templates/post-reply.template', { user: context.user, tid: tid }).then (node) ->
              $thread.append node
              self.bind()
        )
        render()

  showPreview: (event) ->
      source = $(event.target).val()
      preview = $('.post-preview')
      preview.html Agora.utils.md2html(source)
      $(event.target).hide()
      preview.show()

  hidePreview: (event) ->
      $('.post-preview').hide()
      $('.post-source').show().focus()

  submit: (event) ->


