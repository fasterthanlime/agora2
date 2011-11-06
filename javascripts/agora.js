(function() {
  var HOST, app;
  HOST = 'http://192.168.1.64:3000/';
  app = $.sammy('#main', function() {
    var showdown;
    this.use('Template');
    this.use('Mustache');
    showdown = new Showdown.converter();
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
          this.trigger('setup-new-thread-hooks');
          category.threads.forEach(function(thread) {
            return thread.category = category;
          });
          return this.renderEach('templates/thread-summary.template', 'thread', category.threads).appendTo('.threads');
        });
      });
    });
    this.get('#/:slug/:tid', function(context) {
      var thread_id;
      thread_id = this.params['tid'];
      return $.ajax({
        url: HOST + 'thread/' + thread_id,
        dataType: 'json',
        success: function(thread) {
          var user;
          user = {
            nickname: thread.nickname,
            slogan: "Un pour tous, tous pour un",
            avatar: ""
          };
          return context.partial('templates/thread.template', {
            thread: thread
          }).then(function() {
            thread.posts.forEach(function(post) {
              var content;
              content = showdown.makeHtml(post.source);
              return context.render('templates/post.template', {
                post: {
                  content: content,
                  user: user
                }
              }).appendTo('.thread');
            });
            return context.render('templates/post-reply.template', {
              post: {
                user: user,
                thread: thread_id
              }
            }).appendTo('.thread');
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
      return $('.post-title').focus(function() {
        return $('.new-post').slideDown();
      });
    });
    this.bind('setup-post-editor', function() {
      var context;
      context = this;
      $('.submit-post').click(function() {
        return context.trigger('new-thread');
      });
      $('.post-content').blur(function() {
        var text;
        text = showdown.makeHtml($('.post-content').val());
        $('.post-preview').html(text).show();
        return $('.post-content').hide();
      });
      return $('.post-preview').click(function() {
        $('.post-preview').hide();
        return $('.post-content').show().focus();
      });
    });
    return this.bind('new-thread', function(context) {
      context = this;
      return $.ajax({
        url: HOST + 'new-thread',
        type: 'POST',
        data: {
          username: "bluesky",
          category: $('.post-category').val(),
          title: $('.post-title').val(),
          source: $('.post-content').val()
        },
        success: function(data) {
          return alert("Should make the post a real one! Huhu");
        }
      });
    });
  });
  $(function() {
    return app.run('#/');
  });
}).call(this);
