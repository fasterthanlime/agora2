
@Agora = 
  app: null,
  views: {}

@Agora.app = $.sammy '#main', ( app ) ->
  @use 'Template'
  @use 'Storage'
  @use 'Session'

  app.storage = null
  app.gateway = null
  app.remote = null
  app.redirect_to = '#/' # by default, to avoid redirecting to undefined..
  
  @before (context) ->
    @remote = app.remote
    @storage = app.storage
    @user = @session 'user'

    if context.path != '#/login'
      if !@remote && context.path != '#/resume'
        app.redirect_to = context.path
        context.log 'Resuming, will redirect to ' + app.redirect_to + ' when done.'
        context.redirect '#/resume'
      if !@user
        $('.user-info').fadeOut()
        @redirect('#/login')
        return false
      if !@storage
        @storage = new Agora.Storage(@session, @remote)
        app.storage = @storage
      $('.nickname').text(@user.nickname)
      $('.avatar').attr('src', @user.avatar)
      $('.user-info').fadeIn()

  @bind 'run', ->
    context = @
    @trigger 'before-dnode-connect'
    DNode.connect (gateway) ->
      app.gateway = gateway
      context.trigger 'after-dnode-connect'

  @bind 'before-dnode-connect', ->
    context = @
    context.log 'Connecting to dnode'
    @$element().hide()
    
  @bind 'after-dnode-connect', (context) ->
    context = @
    context.log 'Just connected via dnode'
    if @session('token')
      app.gateway.resume @session('token'), (result) ->
        if result.status == 'success'
          app.remote = result.remote
          context.log 'Resumed!, can now go back to ' + app.redirect_to
          context.redirect app.redirect_to
        else
          context.log 'Could not resume session, forced log off'
          $('.user-info').fadeOut()
          context.session('token', null)
          context.session('user', null)
          context.redirect '#/login'
    @$element().fadeIn()

  @get '#/resume', (context) ->
    context.log 'So, resume huh?'

  # Others' profile pages
  @get '#/u/:username', (context) ->
    view = new Agora.views.Profile(context)
    view.render @params.username

  # Own profile page
  @get '#/u', (context) ->
    view = new Agora.views.Profile(context)
    view.render context.user.username

  # Login box
  @get '#/login', (context) ->
    view = new Agora.views.Login(context)
    view.render().then -> view.bind()

  @get '#/logout', (context) ->
    $('.user-info').fadeOut()
    @remote 'logout', ->
      context.log 'Logged out gracefully!'
      # Note that if we don't, it's no biggie. Token
      # will end up expiring anyways.
    @session('user', null)
    @session('token', null)
    # Couldn't find a good way to clear, nulling works just as fine
    @redirect('#/login')

  # Category list
  @get '#/', (context) ->
    view = new Agora.views.Categories(context)
    view.render()

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
