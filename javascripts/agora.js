(function($) {
  var app = $.sammy('#main', function() {
    this.use('Template');

    this.get('#/', function(context) {
      context.app.swap('');
      context.$element().html("Booya");
    });

    this.bind('run', function() {});

  });

  $(function() {
    app.run('#/');
  });
})(jQuery);
