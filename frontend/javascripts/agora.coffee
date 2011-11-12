class Storage
  constructor: (@session, @remote) ->
    # TODO: restore freshness from local storage 
    # along with other saved data
    @lastUpdate = -1
    @tables = {}
    @callbacks = {}

    console.log 'Storage initialized with freshness', @lastUpdate
    if @lastUpdate == -1
      self = @
      @remote 'getSnapshot', (tableName, data) ->
        self.store(tableName, data)
        self.callbacks[tableName] ||= []
        self.callbacks[tableName].forEach (cb) ->
          cb(self.tables[tableName])
        self.callbacks[tableName] = []

  store: (tableName, data) ->
    query = TAFFY(data)
    @tables[tableName] = { present: true, query: query }
    console.log 'Just stored table', tableName, 'it has', query().count(), 'elements'

  get: (tableName, cb) ->
    console.log 'Retrieving table', tableName
    if (@tables.hasOwnProperty tableName)
      console.log 'Immediate retrieval of', tableName
      cb @tables[tableName]
    else
      console.log 'Queuing callback for retrieval of', tableName
      @callbacks[tableName] ||= []
      @callbacks[tableName].push cb

  save: ->
    console.log 'TODO: implement Storage::save'

app = $.sammy '#main', ( app ) ->
  
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
        console.log 'Resuming, will redirect to ' + app.redirect_to + ' when done.'
        context.redirect '#/resume'
      if !@user
        $('.user-info').fadeOut()
        @redirect('#/login')
        return false
      if !@storage
        @storage = new Storage(@session, @remote)
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
    console.log 'before-dnode-connect'
    @$element().hide()
    
  @bind 'after-dnode-connect', ->
    context = @
    console.log 'after-dnode-connect'
    if @session('token')
      app.gateway.resume @session('token'), (result) ->
        if result.status == 'success'
          app.remote = result.remote
          console.log 'Resumed!, can now go back to ' + app.redirect_to
          context.redirect app.redirect_to
        else
          console.log 'Could not resume session, forced log off'
          $('.user-info').fadeOut()
          context.session('token', null)
          context.session('user', null)
          context.redirect '#/login'
    @$element().fadeIn()

  @get '#/resume', (context) ->
    console.log 'So, resume huh?'

  # Others' profile pages
  @get '#/u/:username', (context) ->
    username = @params.username
    context.storage.get 'users', (User) ->
      user = User.query({ username: username }).first()
      context.partial('templates/profile.template', { user: user, date: @utils.formatDate(user.joindate) })

  # Own profile page
  @get '#/u', (context) ->
    context.storage.get 'users', (User) ->
      user = User.query({ username: context.user.username }).first()
      context.partial('templates/profile.template', { user: user, date: @utils.formatDate(user.joindate) })

  # Login box
  @get '#/login', (context) ->
    @partial('templates/login.template').then ->
      $('#password').keypress (event) ->
        return unless event.which == 13
        event.preventDefault()
        # TODO: Change this ASAP! SHA-1( password )
        app.gateway.login $('#login').val(), $('#password').val(), {
          onLogin: (result) ->
            app.remote = result.remote
            if (result.status != 'success')
              console.log 'Error while logging in: ' + result
            else
              context.session 'user', result.session.user
              context.session 'token', result.session.token
              context.redirect app.redirect_to
        }

  @get '#/logout', (context) ->
    $('.user-info').fadeOut()
    @remote 'logout', ->
      console.log 'Logged out gracefully!'
      # Note that if we don't, it's no biggie. Token
      # will end up expiring anyways.
    @session('user', null)
    @session('token', null)
    # Couldn't find a good way to clear, nulling works just as fine
    @redirect('#/login')

  # Category list
  @get '#/', (context) ->
    @partial('templates/home.template').then ->
      context.storage.get 'categories', (table) ->
        tables = table.query().get()
        render0 = (i) ->
          category = tables[i]
          context.render('templates/category-summary.template', { category: category }).then (elem) ->
            $(elem).appendTo('.categories')
            if i + 1 < tables.length
              render0 i + 1
        render0 0

  # Thread list in a category
  @get '#/r/:slug', (context) ->
    @slug = @params['slug']

    context.storage.get 'categories', (Category) ->
      category = Category.query({ slug: context.slug }).first()
      context.partial('templates/category.template', { category: category }).then ->
        threads = category.threads
        context.storage.get 'threads', (Thread) ->
          render0 = (i) ->
            thread = Thread.query({ _id: threads[i] }).first()
            thread.category = category
            context.render('templates/thread-summary.template', { thread: thread }).then (threadnode) ->
              $(threadnode).appendTo('.threads')
              if i + 1 < threads.length
                render0 i + 1
          render0 0

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
              content = @utils.md2html(post.source)
              context.render('templates/post.template', post: { content: content, date: @utils.formatDate(post.date), user: user }).then (postnode) ->
                $(postnode).appendTo('.thread')
                if i + 1 < posts.length
                  render0 i + 1
            render0 0

$ -> app.run '#/'
