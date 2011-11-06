# Simple sammy test in CS :)

HOST = 'http://192.168.1.64:3000/'
showdown = new Showdown.converter()

app = $.sammy '#main', ->
  @use 'Template'
  @use 'Storage'
  @use 'Session'

  get_user = (username, cb) ->
    user = @session('user/' + username)
    if user
      cb(user)
    else
      $.get(HOST + 'user/' + username, {}, (data) -> cb(data))

  @before (context) ->
    @user = @session('user')
    @get_user = (username, data) -> get_user.apply(@, [username, data])
    if context.path != '#/login'
      if !@user
        $('.user-info').fadeOut()
        @redirect('#/login')
        return false
      $('.nickname').text(@user.nickname)
      $('.avatar').attr('src', @user.avatar)
      $('.user-info').fadeIn()

  @bind 'render-all', (event, args) ->
    @load(HOST + args.path, { json: true }).then (content) ->
      @renderEach(args.template, args.name, content).appendTo(args.target)

  # Login box
  @get '#/login', (context) ->
    @partial('templates/login.template').then ->
      $('#password').keypress (event) ->
        return unless event.which == 13
        event.preventDefault()
        $.post HOST + 'login', { login: $('#login').val(), password: $('#password').val() }, (data) ->
          context.log data
          switch data.result
            when "failure"
              context.log "Log-in failed!"
            when "success"
              context.log "Log-in succeeded!"
              context.session('user', data.user)
              context.session('token', data.session_token)
              context.redirect('#/')

  @get '#/logout', (context) ->
    $('.user-info').fadeOut()
    $.post HOST + 'logout', { token: @session('token') }, (data) ->
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
      path: 'categories'
      template: 'templates/category-summary.template'
      name: 'category'
      target: '.categories'
    }

  # Thread list in a category
  @get '#/r/:slug', (context) ->
    slug = @params['slug']

    @load(HOST + 'category/' + slug, { json: true }).then (category) ->
      context.partial 'templates/category.template', { category: category }
      context.render('templates/new-thread.template', { post: { user: context.user, category: category._id }}).appendTo('.threads').then ->
        @trigger 'setup-thread-opener'
        @trigger 'setup-post-editor'
        category.threads.forEach (thread) -> thread.category = category
        @renderEach('templates/thread-summary.template', 'thread', category.threads).appendTo('.threads')

  # Message list in a thread
  @get '#/r/:slug/:tid', (context) ->
    tid = @params['tid']
    $.ajax({
      url: HOST + 'thread/' + tid
      dataType: 'json'
      success: (thread) ->
        context.partial('templates/thread.template', {thread: thread}).then ->
          render0 = (index) ->
            if index < thread.posts.length
              post = thread.posts[index]
              content = showdown.makeHtml(post.source)
              context.get_user post.username, (post_user) ->
                context.render('templates/post.template', {post: {content: content, user: post_user}}).then (post) ->
                  $(post).hide().appendTo('.thread').fadeIn('slow')
                  render0(index + 1)
            else
              context.render('templates/post-reply.template', {post: {user: context.user, tid: tid}}).then (post) ->
                $(post).hide().appendTo('.thread').fadeIn('slow')
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
    $.post HOST + 'post-reply', {
        username: @user.username
        tid: tid
        source: $('.post-source').val()
    }, (data) ->
      post = {
        username: $('.new-post .nickname').text()
        source: $('.post-source').val()
      }
      content = showdown.makeHtml(post.source)
      context.render('templates/post.template', {post: {content: content, user: context.user}}).then (postnode) ->
        $(postnode).hide().appendTo('.thread').slideDown()
        $('.new-post').detach().appendTo('.thread')
        $('.post-preview').click()
        $('.post-source').val('')

  @bind 'new-thread', (context) ->
    context = @
    $.post HOST + 'new-thread', {
        username: @user.username
        category: $('.post-category').val()
        title: $('.post-title').val()
        source: $('.post-source').val()
    }, (data) ->
      alert("new thread successful")

$ -> app.run '#/'
