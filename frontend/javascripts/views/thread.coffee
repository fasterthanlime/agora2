
class @Agora.views.Thread extends @Agora.View
  
  events:
    'click .submit-post' : 'submit',
    'blur .post-source' : 'showPreview',
    'click .post-preview' : 'hidePreview',

  appEvents: [ 'onPost' ]

  render: (params) ->
    self = @
    context = @context

    @tid = params.tid

    context.storage.get (db) ->
      thread = db.Thread({ _id: self.tid }).first()
      category = db.Category({ _id: thread.category }).first() 
      posts = thread.posts.slice().reverse() # MongoDB sorts by IDs, we need desc
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
            context.render('templates/post-reply.template', { user: context.user, tid: self.tid }).then (node) ->
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
    post = {
      thread: @tid,
      user: @context.user._id,
      source: $('.post-source').val(),
    }
    @context.storage.addPost post, ->
    @app.trigger 'onPost', post

  onPost: (post) ->
    context = @context
    if (post.thread != @tid)
      return
    context.storage.get (db) ->
      content = Agora.utils.md2html post.source
      context.render( 'templates/post.template', post: {
        content: content
        date: Agora.utils.formatDate post.date
        user: db.User({ _id: post.user }).first()
      }).then (node) ->
        $(node).insertBefore('.new-post')
        $('body').scrollTo('.new-post', 500)

