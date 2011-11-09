# Simple sammy test in CS :)

showdown = new Showdown.converter()

app = $.sammy '#main', ( app ) ->
  
  @use 'Template'
  @use 'Storage'
  @use 'Session'
  
  app.remote = null
  
  getUser = (username, cb) ->
    user = @session('user/' + username)
    if user
      cb(user)
    else
      $.get('/user/' + username, {}, (data) -> cb(data))

  formatDate = (timestamp) ->
    pad = (number) ->
      if number < 10 
        '0' + number
      else
        '' + number
    date = new Date(timestamp)
    pad(date.getDate()) + " " + ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"][date.getMonth()] + " " + date.getFullYear() + " à " + pad(date.getHours()) + ":" + pad(date.getMinutes()) + ":" + pad(date.getSeconds())

  @before (context) ->
    @user = @session 'user'
    @getUser = (username, data) -> getUser.apply(@, [username, data])
    if context.path != '#/login'
      if !@user
        $('.user-info').fadeOut()
        @redirect('#/login')
        return false
      $('.nickname').text(@user.nickname)
      $('.avatar').attr('src', @user.avatar)
      $('.user-info').fadeIn()

  @bind 'run', ->
    context = @
    @trigger 'before-dnode-connect'
    DNode.connect (remote) ->
      app.remote = remote
      context.trigger 'after-dnode-connect'

  @bind 'before-dnode-connect', ->
    console.log 'before-dnode-connect'
    @$element().hide()
    
  @bind 'after-dnode-connect', ->
    console.log 'after-dnode-connect'
    @$element().fadeIn()
  
  @bind 'render-all', (event, args) ->
    @load('/' + args.path, { json: true }).then (content) ->
      @renderEach(args.template, args.name, content).appendTo(args.target)

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
        app.remote.login $('#login').val(), $('#password').val(), (result) ->
          if (result.status != 'success')
            console.log 'Error while logging in: ', result
          else
            console.log 'Logged in, yay! session = ', result
            context.session 'user', result.session.user
            context.session 'token', result.session.token
            context.redirect '#/'

  @get '#/logout', (context) ->
    $('.user-info').fadeOut()
    $.post '/logout', { token: @session('token') }, (data) ->
      context.log 'Logged out gracefully!'
      # Note that if we don't, it's no biggie. Token
      # will end up expiring anyways.
    @session('user', null)
    @session('token', null)
    # Couldn't find a good way to clear, nulling works just as fine
    @redirect('#/login')

  # Category list
  @get '#/', (context) ->
    @partial('templates/home.template')
    @trigger 'render-all', {
      path: 'categories?token=' + @session('token')
      template: 'templates/category-summary.template'
      name: 'category'
      target: '.categories'
    }

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
