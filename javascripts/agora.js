(function() {
  var FAKE_USER, FAKE_USERNAME, HOST, app, showdown;
  HOST = 'http://192.168.1.64:3000/';
  showdown = new Showdown.converter();
  FAKE_USERNAME = 'bluesky';
  FAKE_USER = {
    nickname: FAKE_USERNAME,
    slogan: "Un pour tous, tous pour un",
    avatar: HOST + "stylesheets/avatar1.png"
  };
  app = $.sammy('#main', function() {
    this.use('Template');
    this.bind('render-all', function(event, args) {
      return this.load(HOST + args.path, {
        json: true
      }).then(function(content) {
        return this.renderEach(args.template, args.name, content).appendTo(args.target);
      });
    });
    this.get('#/', function(context) {
      context.app.swap('');
      this.partial('templates/home.template');
      return this.trigger('render-all', {
        path: 'categories',
        template: 'templates/category-summary.template',
        name: 'category',
        target: '.categories'
      });
    });
    this.get('#/:slug', function(context) {
      var him, me, slug;
      me = {
        nickname: "BlueSky",
        slogan: "Win j'en ai eu ma dows, COMME MA BITE",
        avatar: "/stylesheets/avatar2.png"
      };
      him = {
        nickname: "Sylvain",
        slogan: "Mousse de canard",
        avatar: "/stylesheets/avatar1.png"
      };
      slug = this.params['slug'];
      return this.load(HOST + 'category/' + slug, {
        json: true
      }).then(function(category) {
        context.partial('templates/category.template', {
          category: category
        });
        return context.render('templates/new-thread.template', {
          post: {
            user: me,
            category: category._id
          }
        }).appendTo('.threads').then(function() {
          this.trigger('setup-thread-opener');
          this.trigger('setup-post-editor');
          category.threads.forEach(function(thread) {
            return thread.category = category;
          });
          return this.renderEach('templates/thread-summary.template', 'thread', category.threads).appendTo('.threads');
        });
      });
    });
    this.get('#/:slug/:tid', function(context) {
      var tid;
      tid = this.params['tid'];
      return $.ajax({
        url: HOST + 'thread/' + tid,
        dataType: 'json',
        success: function(thread) {
          return context.partial('templates/thread.template', {
            thread: thread
          }).then(function() {
            var render0;
            render0 = function(index) {
              var content, post;
              if (index < thread.posts.length) {
                post = thread.posts[index];
                content = showdown.makeHtml(post.source);
                return context.render('templates/post.template', {
                  post: {
                    content: content,
                    user: FAKE_USER
                  }
                }).appendTo('.thread').then(function() {
                  return render0(index + 1);
                });
              } else {
                return context.render('templates/post-reply.template', {
                  post: {
                    user: FAKE_USER,
                    tid: tid
                  }
                }).appendTo('.thread').then(function() {
                  this.trigger('setup-post-editor');
                  return $('.submit-post').click(function() {
                    return context.trigger('post-reply', {
                      context: context
                    });
                  });
                });
              }
            };
            return render0(0);
          });
        }
      });
    });
    this.bind('setup-thread-opener', function() {
      var context;
      context = this;
      $('.post-title').blur(function() {
        if ($(this).val() === "") {
          return $('.new-post').slideUp();
        }
      });
      $('.post-title').focus(function() {
        return $('.new-post').slideDown();
      });
      return $('.submit-post').click(function() {
        return context.trigger('new-thread');
      });
    });
    this.bind('setup-post-editor', function() {
      var context;
      context = this;
      $('.post-source').blur(function() {
        var preview, source;
        source = $(this);
        source.hide();
        preview = source.parent().children('.post-preview');
        return preview.html(showdown.makeHtml(source.val())).show();
      });
      return $('.post-preview').click(function() {
        var preview, source;
        preview = $(this);
        preview.hide();
        source = preview.parent().children('.post-source');
        return source.show().focus();
      });
    });
    this.bind('post-reply', function(context) {
      var tid;
      context = this;
      tid = $('.reply-thread').val();
      return $.post(HOST + 'post-reply', {
        username: FAKE_USERNAME,
        tid: tid,
        source: $('.post-source').val()
      }, function(data) {
        var content, post;
        post = {
          username: $('.new-post .nickname').text(),
          source: $('.post-source').val()
        };
        content = showdown.makeHtml(post.source);
        return context.render('templates/post.template', {
          post: {
            content: content,
            user: FAKE_USER
          }
        }).then(function(postnode) {
          $(postnode).hide().appendTo('.thread').slideDown();
          $('.new-post').detach().appendTo('.thread');
          $('.post-preview').click();
          return $('.post-source').val('');
        });
      });
    });
    return this.bind('new-thread', function(context) {
      return $.post(HOST + 'new-thread', {
        username: "bluesky",
        category: $('.post-category').val(),
        title: $('.post-title').val(),
        source: $('.post-source').val()
      }, function(data) {
        return alert("new thread successful");
      });
    });
  });
  $(function() {
    return app.run('#/');
  });
}).call(this);
