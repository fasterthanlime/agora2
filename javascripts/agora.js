(function() {
  var app;
  app = $.sammy('#main', function() {
    this.use('Template');
    this.get('#/', function(context) {
      context.app.swap('');
      return context.$element().html("Booya");
    });
    this.get('#/category/:id/new', function(context) {
      var him, me, thread, thread_id;
      thread_id = "chats123";
      me = {
        nickname: "BlueSky",
        slogan: "Win j'en ai eu ma dows",
        avatar: ""
      };
      him = {
        nickname: "Sylvain",
        slogan: "Win j'en ai eu ma dows",
        avatar: ""
      };
      this.render('templates/thread.template', {
        thread: {
          id: thread_id
        }
      }).appendTo(this.$element());
      thread = '#' + thread_id;
      this.render('templates/new-thread.template', {
        post: {
          user: him
        }
      }).appendTo(thread);
      this.render('templates/post.template', {
        post: {
          user: me,
          content: "Les anarchistes c'est le bien!"
        }
      }).appendTo(thread);
      this.render('templates/post.template', {
        post: {
          user: him,
          content: "Merde"
        }
      }).appendTo(thread);
      return this.render('templates/post.template', {
        post: {
          user: me,
          content: "On retrouve une idée commune avec Kadoc."
        }
      }).appendTo(thread);
    });
    return this.bind('run', function() {});
  });
  $(function() {
    return app.run('#/');
  });
}).call(this);
