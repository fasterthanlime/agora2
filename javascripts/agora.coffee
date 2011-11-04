# Simple sammy test in CS :)

app = $.sammy '#main', ->
  @use 'Template'

  @get '#/', (context) ->
    context.app.swap ''
    #@partial('templates/home.template')

  @get '#/category/:id/new', (context) ->
    thread_id = "chats123"
    me  = {nickname: "BlueSky", slogan: "Win j'en ai eu ma dows, COMME MA BITE", avatar: "/stylesheets/avatar2.png"}
    him = {nickname: "Sylvain", slogan: "Mousse de canard", avatar: "/stylesheets/avatar1.png"}
    @partial('templates/thread.template', {thread: { id: thread_id }}).appendTo(@$element())
    thread = '#' + thread_id
    @render('templates/new-thread.template', {post: { user: him }}).appendTo(thread)
    @render('templates/post.template', {post: { user: me, content: "Les anarchistes c'est le bien!" }}).appendTo(thread)
    @render('templates/post.template', {post: { user: him, content: "Merde" }}).appendTo(thread)
    @render('templates/post.template', {post: { user: me, content: "On retrouve une idée commune avec Kadoc." }}).appendTo(thread)
    @render('templates/post.template', {post: { user: him, content: "Il m'énerve lui" }}).appendTo(thread)

  @bind 'run', ->

$ -> app.run '#/'
