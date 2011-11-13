
@Agora.app = $.sammy '#main', ( app ) ->
  @use 'Template'
  @use 'Storage'
  @use 'Session'

  setupSession.apply @, [app]

  # Login box
  @get '#/login', (context) ->
    view = new Agora.views.Login(context)
    view.render().then -> view.bind()

  # Category list
  @get '#/', (context) ->
    view = new Agora.views.Categories(context)
    view.render()

  # Profile page
  @get '#/u/:username', (context) ->
    view = new Agora.views.Profile(context)
    view.render @params.username

  # Own profile page
  @get '#/u', (context) ->
    context.redirect '#/u/' + context.user.username

  # Thread list in a category
  @get '#/r/:slug', (context) ->
    view = new Agora.views.Threads(context)
    view.render(@params)

  # Message list in a thread
  @get '#/r/:slug/:tid', (context) ->
    tid = @params['tid']

    context.storage.get 'threads', (Thread) ->
      thread = Thread.query({ _id: tid }).first()
      posts = thread.posts
      context.partial('templates/thread.template', { thread: thread}).then ->
        context.storage.get 'posts', (Post) ->
          context.storage.get 'users', (User) ->
            render0 = (i) ->
              post = Post.query({ _id: posts[i] }).first()
              user = User.query({ _id: post.user }).first()
              content = @Agora.utils.md2html(post.source)
              context.render('templates/post.template', post: { content: content, date: @Agora.utils.formatDate(post.date), user: user }).then (postnode) ->
                $(postnode).appendTo('.thread')
                if i + 1 < posts.length
                  render0 i + 1
            render0 0

$ -> Agora.app.run '#/'
