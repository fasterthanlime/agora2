(function() {
  var HOST, app;
  HOST = 'http://192.168.1.64:3000/';
  app = $.sammy('#main', function() {
    this.use('Template');
    this.get('#/', function(context) {
      context.app.swap('');
      this.partial('templates/home.template');
      return $.ajax({
        url: HOST + 'categories',
        dataType: 'json',
        success: function(data) {
          return data.forEach(function(category) {
            return context.render('templates/category-summary.template', {
              category: category
            }).appendTo('.categories');
          });
        }
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
      return $.ajax({
        url: HOST + 'category/' + slug,
        dataType: 'json',
        success: function(data) {
          return context.partial('templates/category.template', {
            category: data.category
          }).then(function() {
            return context.render('templates/new-thread.template', {
              post: {
                user: me,
                category: data.category._id
              }
            }).appendTo('.threads').then(function() {
              this.trigger('setup-new-thread-hooks');
              return data.category.threads.forEach(function(thread) {
                return context.render('templates/thread-summary.template', {
                  category: data.category,
                  thread: thread
                }).appendTo('.threads');
              });
            });
          });
        }
      });
    });
    this.get('#/:slug/:tid', function(context) {
      var thread_id;
      thread_id = this.params['tid'];
      return $.ajax({
        url: HOST + 'thread/' + thread_id,
        dataType: 'json',
        success: function(data) {
          var user;
          user = {
            nickname: data.thread.nickname,
            slogan: "Un pour tous, tous pour un",
            avatar: ""
          };
          return context.partial('templates/thread.template', {
            thread: data.thread
          }).then(function() {
            var converter;
            converter = new Showdown.converter();
            return data.thread.posts.forEach(function(post) {
              var text;
              text = converter.makeHtml(post.source);
              return context.render('templates/post.template', {
                post: {
                  content: text,
                  user: user
                }
              }).appendTo('.thread').then(function() {
                return context.render('templates/post-reply.template', {
                  post: {
                    user: user,
                    thread: thread_id
                  }
                }).appendTo('.thread');
              });
            });
          });
        }
      });
    });
    this.bind('setup-new-thread-hooks', function() {
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
      $('.submit-post').click(function() {
        return context.trigger('new-thread');
      });
      $('.post-content').blur(function() {
        var converter, text;
        converter = new Showdown.converter();
        text = converter.makeHtml($('.post-content').val());
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
