
class @Agora.views.Thread extends @Agora.View
  
  events:
    'click .submit-post' : 'submit',
    'blur .post-source' : 'showPreview',
    'keypress .post-source' : 'keyPress',
    'click .post-preview' : 'hidePreview',
    'click .post-admin-delete' : 'delete',

  appEvents: [ 'onPost' ]

  render: (params) ->
    self = @
    context = @context

    @tid = params.tid

    context.storage.get (db) ->
      thread = db.Thread({ _id: self.tid }).first()
      category = db.Category({ _id: thread.category }).first()
      posts = thread.posts.slice().reverse() # MongoDB sorts by IDs, we need desc

      isAdmin = true # FIXME that's not true.
      postTemplate = if isAdmin then 'post-admin' else 'post'
      context.partial('templates/thread.template', { category: category, thread: thread }).then ->
        $thread = $ '.thread'
        render = self.getRenderer(
          posts,
          postTemplate,
          (record) ->
            post = db.Post({ _id: record }).first()
            content = Agora.utils.md2html post.source
            post: {
              id: record
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

  keyPress: (event) ->
    # console.log event
    if ((event.charCode == 13 || event.charCode == 10) && event.ctrlKey)
      $('.submit-post').click()
      return false

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
      thread: @tid
      user: @context.user._id
      source: $('.post-source').val()
      date: Date.now()
    }
    @context.storage.addPost post, ->
    @app.trigger 'onPost', post

    $('.post-source').val('')
    $('.post-preview').click()
    
  delete: (event) ->
    postID = $(event.target).parents('.post').attr('data-id')
    threadID = @tid
    console.log 'Deleting post', postID, 'from thread', threadID
    @context.storage.deletePost ({
      postID: postID
      threadID: threadID
    })
    
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

