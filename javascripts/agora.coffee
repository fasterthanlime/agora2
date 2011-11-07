# Simple sammy test in CS :)

HOST = 'http://ldmf.ch/'
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

  format_date = (timestamp) ->
    pad = (number) ->
      if number < 10 
        '0' + number
      else
        '' + number
    date = new Date(timestamp)
    pad(date.getDate()) + " " + ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"][date.getMonth()] + " " + date.getFullYear() + " à " + pad(date.getHours()) + ":" + pad(date.getMinutes()) + ":" + pad(date.getSeconds())

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

  # Others' profile pages
  @get '#/u/:username', (context) ->
    username = @params.username
    $.get HOST + 'user/' + username, {}, (user) ->
      context.partial('templates/profile.template', { user: user, date: format_date(user.joindate) })

  # Own profile page
  @get '#/u', (context) ->
    $.get HOST + 'user/' + @user.username, {}, (user) ->
      context.partial('templates/profile.template', { user: user, date: format_date(user.joindate) })

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
    @slug = @params['slug']

    $.get HOST + 'category/' + @slug, {}, (category) ->
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
      url: HOST + 'thread/' + tid
      dataType: 'json'
      success: (thread) ->
        context.partial('templates/thread.template', {thread: thread}).then ->
          render0 = (index) ->
            if index < thread.posts.length
              post = thread.posts[index]
              content = showdown.makeHtml(post.source)
              context.get_user post.username, (post_user) ->
                context.render('templates/post.template', {post: {content: content, date: format_date(post.date), user: post_user}}).then (post) ->
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
    $.post HOST + 'post-reply', {
        username: @user.username
        tid: tid
        source: $('.post-source').val()
    }, (data) ->
      content = showdown.makeHtml($('.post-source').val())
      context.render('templates/post.template', {post: {content: content, user: context.user, date: format_date(data.date)}}).then (postnode) ->
        $(postnode).hide().appendTo('.thread').slideDown()
        $('.new-post').detach().appendTo('.thread')
        $('.post-preview').click()
        $('.post-source').val('')

  @bind 'new-thread', (context) ->
    context = @
    category = $('.post-category').val()
    title = $('.post-title').val()
    $.post HOST + 'new-thread', {
        username: @user.username
        category: category
        title: title
        source: $('.post-source').val()
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
