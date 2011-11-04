# Simple sammy test in CS :)

HOST = 'http://192.168.1.64:3000/'

app = $.sammy '#main', ->
  @use 'Template'

  @get '#/', (context) ->
    context.app.swap ''
    @partial('templates/home.template')
    $.ajax({
      url: HOST + 'categories'
      dataType: 'json'
      success: (data) -> data.forEach (category) ->
        context.render('templates/category-summary.template', {category: category}).appendTo('.categories')
    })

  @get '#/:slug', (context) ->
    me = {nickname: "BlueSky", slogan: "Win j'en ai eu ma dows, COMME MA BITE", avatar: "/stylesheets/avatar2.png"}
    him = {nickname: "Sylvain", slogan: "Mousse de canard", avatar: "/stylesheets/avatar1.png"}
    slug = @params['slug']

    $.ajax({
      url: HOST + 'category/' + slug
      dataType: 'json'
      success: (data) ->
        context.partial('templates/category.template', {category: data.category}).then ->
          context.render('templates/new-thread.template', { post: { user: me, category: data.category._id }}).appendTo('.threads').then ->
            @trigger 'setup-new-thread-hooks'
    })

  @bind 'setup-new-thread-hooks', ->
    context = @
    $('.post-title').blur ->
      if $(this).val() == ""
        $('.new-post').slideUp()

    $('.post-title').focus ->
      $('.new-post').slideDown()

    $('.submit-post').click ->
      context.trigger 'new-thread'

    $('.post-content').blur ->
      converter = new Showdown.converter()
      text = converter.makeHtml($('.post-content').val())
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
