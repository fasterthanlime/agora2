(function() {
  var app;
  app = $.sammy('#main', function() {
    this.use('Template');
    this.get('#/', function(context) {
      context.app.swap('');
      return context.$element().html("Booya");
    });
    return this.bind('run', function() {});
  });
  $(function() {
    return app.run('#/');
  });
}).call(this);
