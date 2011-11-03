(function() {
  var app;
  app = $.sammy('#main', function() {
    this.use('Template');
    this.get('#/', function(context) {
      context.app.swap('');
      return context.$element().html("Booya");
    });
    this.get('#/category/:id/new', function(context) {
      return this.partial('templates/new-thread.template');
    });
    return this.bind('run', function() {});
  });
  $(function() {
    return app.run('#/');
  });
}).call(this);
