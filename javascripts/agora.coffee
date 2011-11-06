# Simple sammy test in CS :)

HOST = 'http://192.168.1.64:3000/'

app = $.sammy '#main', ->
  @use 'Template'
  @use 'Mustache'

  showdown = new Showdown.converter()

  @bind 'render-all', (event, args) ->
    @load(HOST + args.path, { json: true }).then (content) ->
      @renderEach(args.template, args.name, content).appendTo(args.target)

  @get '#/', (context) ->
    context.app.swap ''
    @partial('templates/home.template')
    @trigger 'render-all', {
      path: 'categories'
      template: 'templates/category-summary.template'
      name: 'category'
      target: '.categories'
    }

  @get '#/:slug', (context) ->
    me = {nickname: "BlueSky", slogan: "Win j'en ai eu ma dows, COMME MA BITE", avatar: "/stylesheets/avatar2.png"}
    him = {nickname: "Sylvain", slogan: "Mousse de canard", avatar: "/stylesheets/avatar1.png"}
    slug = @params['slug']

    @load(HOST + 'category/' + slug, { json: true }).then (category) ->
      context.partial 'templates/category.template', { category: category }
      context.render('templates/new-thread.template', { post: { user: me, category: category._id }}).appendTo('.threads').then ->
        @trigger 'setup-new-thread-hooks'
        category.threads.forEach (thread) -> thread.category = category
        @renderEach('templates/thread-summary.template', 'thread', category.threads).appendTo('.threads')

  @get '#/:slug/:tid', (context) ->
    thread_id = @params['tid']
    $.ajax({
      url: HOST + 'thread/' + thread_id
      dataType: 'json'
      success: (thread) ->
        user = {
          nickname: thread.nickname
          slogan: "Un pour tous, tous pour un"
          avatar: ""
        }
        context.partial('templates/thread.template', {thread: thread}).then ->
          thread.posts.forEach (post) ->
            content = showdown.makeHtml(post.source)
            context.render('templates/post.template', {post: {content: content, user: user}}).appendTo('.thread')
          context.render('templates/post-reply.template', {post: {user: user, thread: thread_id}}).appendTo('.thread')

    })

  @bind 'setup-thread-opener', ->
    context = @
    $('.post-title').blur ->
      if $(this).val() == ""
        $('.new-post').slideUp()

    $('.post-title').focus ->
      $('.new-post').slideDown()

  @bind 'setup-post-editor', ->
    context = @
    $('.submit-post').click ->
      context.trigger 'new-thread'

    $('.post-content').blur ->
      text = showdown.makeHtml($('.post-content').val())
      $('.post-preview').html(text).show()
      $('.post-content').hide()

    $('.post-preview').click ->
      $('.post-preview').hide()
      $('.post-content').show().focus()

  @bind 'new-thread', (context) ->
    context = @
    $.ajax({
      url: HOST + 'new-thread'
      type: 'POST',
      data: {
        username: "bluesky"
        category: $('.post-category').val()
        title: $('.post-title').val()
        source: $('.post-content').val()
      }
      success: (data) ->
        alert("Should make the post a real one! Huhu")
    })

$ -> app.run '#/'
