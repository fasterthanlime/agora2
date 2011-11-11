
showdown = new Showdown.converter()

allDefined = (object, fields) ->
  console.log 'Testing for fields', fields, 'in object', JSON.stringify object
  result = true
  fields.forEach (field) ->
    if !(object.hasOwnProperty field)
      console.log 'Missing key', field, 'in object', JSON.stringify object
      result = false
  result

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
  
  formatDate = (timestamp) ->
    pad = (number) ->
      if number < 10 
        '0' + number
      else
        '' + number
    date = new Date(timestamp)
    pad(date.getDate()) + " " + ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"][date.getMonth()] + " " + date.getFullYear() + " à " + pad(date.getHours()) + ":" + pad(date.getMinutes()) + ":" + pad(date.getSeconds())

  @before (context) ->
    @remote = app.remote
    @storage = app.storage
    @user = @session 'user'

    if context.path != '#/login'
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
          console.log 'Resumed!'
          context.redirect '#/'
        else
          console.log 'Could not resume session, forced log off'
          $('.user-info').fadeOut()
          context.session('token', null)
          context.session('user', null)
          context.redirect '#/login'
    @$element().fadeIn()
  
  # Others' profile pages
  @get '#/u/:username', { token: @session( 'token' ) }, (context) ->
    username = @params.username
    $.get '/user/' + username, { token: @session( 'token' ) }, (user) ->
      context.partial('templates/profile.template', { user: user, date: formatDate(user.joindate) })

  # Own profile page
  @get '#/u', (context) ->
    $.get '/user/' + @user.username, { token: @session( 'token' ) }, (user) ->
      context.partial('templates/profile.template', { user: user, date: formatDate(user.joindate) })

  # Login box
  @get '#/login', (context) ->
    @partial('templates/login.template').then ->
      $('#password').keypress (event) ->
        return unless event.which == 13
        event.preventDefault()
        # TODO: Change this ASAP! SHA-1( password )
        console.log $('#login').val(), $('#password').val()
        app.gateway.login $('#login').val(), $('#password').val(), {
          onLogin: (result) ->
            app.remote = result.remote
            console.log 'Got remote ', app.remote
            if (result.status != 'success')
              console.log 'Error while logging in: ', result
            else
              console.log 'Logged in, yay! session = ', result
              context.session 'user', result.session.user
              context.session 'token', result.session.token
              context.redirect '#/'
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
        numTables = table.query().count()
        tables = table.query().get()
        render0 = (i) ->
          category = tables[i]
          console.log 'render0(', i, '), category =', category
          context.render('templates/category-summary.template', { category: category }).then (elem) ->
            $(elem).appendTo('.categories')
            if i + 1 < tables.length
              render0 i + 1
        render0 0
    
    #@bind 'render-all', (event, args) ->
    #  @load('/' + args.path, { json: true }).then (content) ->
    #    @renderEach(args.template, args.name, content).appendTo(args.target)


    #@trigger 'render-all', {
    #  path: 'categories?token=' + @session('token')
    #  template: 'templates/category-summary.template'
    #  name: 'category'
    #  target: '.categories'
    #}

  # Thread list in a category
  @get '#/r/:slug', (context) ->
    @slug = @params['slug']

    $.get '/category/' + @slug, { token: @session('token') }, (category) ->
      context.partial 'templates/category.template', { category: category }
      context.render('templates/new-thread.template', { post: { user: context.user, category: category._id }}).prependTo('.threads').then ->
        @trigger 'setup-thread-opener'
        @trigger 'setup-post-editor'
      render0 = (index) ->
        if index < category.threads.length
          thread = category.threads[category.threads.length - 1 - index]
          thread.category = category
          context.render('templates/thread-summary.template', { thread: thread }).then (threadnode) ->
            $(threadnode).appendTo('.threads')
            render0(index + 1)
      render0(0)

  # Message list in a thread
  @get '#/r/:slug/:tid', (context) ->
    tid = @params['tid']
    $.ajax({
      url: '/thread/' + tid
      data: { token: @session( 'token' ) }
      dataType: 'json'
      success: (thread) ->
        context.partial('templates/thread.template', {thread: thread}).then ->
          render0 = (index) ->
            if index < thread.posts.length
              post = thread.posts[index]
              content = showdown.makeHtml(post.source)
              context.getUser post.username, (postUser) ->
                context.render('templates/post.template', {post: {content: content, date: formatDate(post.date), user: postUser}}).then (post) ->
                  $(post).appendTo('.thread')
                  render0(index + 1)
            else
              context.render('templates/post-reply.template', {post: {user: context.user, tid: tid}}).then (post) ->
                $(post).appendTo('.thread')
                @trigger 'setup-post-editor'
                $('.submit-post').click ->
                  context.trigger 'post-reply', { context: context }
          render0(0)
    })

  @bind 'setup-thread-opener', ->
    context = @
    $('.post-title').blur ->
      if $(this).val() == ""
        $('.new-post').slideUp()

    $('.post-title').focus ->
      newpost = $('.new-post')
      if newpost.css('display') == 'none'
        $('.new-post').hide().css('height', '0px').show().animate({height: '191px'})

    $('.submit-post').click ->
      context.trigger 'new-thread'

  @bind 'setup-post-editor', ->
    context = @
    $('.post-source').blur ->
      source = $(this)
      source.hide()
      preview = source.parent().children('.post-preview')
      preview.html(showdown.makeHtml(source.val())).show()

    $('.post-preview').click ->
      preview = $(this)
      preview.hide()
      source = preview.parent().children('.post-source')
      source.show().focus()

  @bind 'post-reply', (context) ->
    context = @
    tid = $('.reply-thread').val()
    $.post '/post-reply', {
        username: @user.username
        tid: tid
        source: $('.post-source').val()
        token: @session('token')
    }, (data) ->
      content = showdown.makeHtml($('.post-source').val())
      context.render('templates/post.template', {post: {content: content, user: context.user, date: formatDate(data.date)}}).then (postnode) ->
        $(postnode).hide().appendTo('.thread').slideDown()
        $('.new-post').detach().appendTo('.thread')
        $('.post-preview').click()
        $('.post-source').val('')

  @bind 'new-thread', (context) ->
    context = @
    category = $('.post-category').val()
    title = $('.post-title').val()
    $.post '/new-thread', {
        username: @user.username
        category: category
        title: title
        source: $('.post-source').val()
        token: @session( 'token' )
    }, (data) ->
      title = $('.new-header .post-title').val()
      context.log title
      $('.new-header, .new-post').remove()
      context.render('templates/thread-summary.template', { thread: { category: { slug: context.slug }, _id: data.id, title: title } }).then (postnode) ->
        $(postnode).hide().prependTo('.threads').slideDown()
        context.render('templates/new-thread.template', { post: { user: context.user, category: category }}).prependTo('.threads').then ->
          @trigger 'setup-thread-opener'
          @trigger 'setup-post-editor'
 

$ -> app.run '#/'
