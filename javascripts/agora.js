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
              return this.trigger('setup-new-thread-hooks');
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
