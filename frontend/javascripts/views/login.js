(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  this.Agora.views.Login = (function() {
    function Login() {
      Login.__super__.constructor.apply(this, arguments);
    }
    __extends(Login, this.Agora.View);
    Login.prototype.events = {
      'keypress #password': 'submit'
    };
    Login.prototype.render = function(data) {
      var html;
      html = this.context.eco('login', data);
      return this.$el().html(html);
    };
    Login.prototype.submit = function(event) {
      if (event.which !== 13) {
        return;
      }
      event.preventDefault();
      return console.log('Logging in with: ', this.$el('#username').val(), this.$el('#password').val());
    };
    return Login;
  }).call(this);
}).call(this);
