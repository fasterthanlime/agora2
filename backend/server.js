(function() {
  var app, express, mongoose, port, schemas, sys;
  sys = require('sys');
  express = require('express');
  mongoose = require('mongoose');
  schemas = require('./schemas');
  app = express.createServer();
  app.register('.html', {
    compile: function(str, options) {
      return function(locals) {
        return str;
      };
    }
  });
  app.use(express.static(__dirname + '/../'));
  app.get('/', function(req, res) {
    return res.render('index.html', {
      layout: false
    });
  });
  app.get('/categories', function(req, res) {
    var Category;
    Category = mongoose.model('Category');
    return Category.find({}, function(err, cats) {
      return res.send(JSON.stringify(cats));
    });
  });
  port = 3000;
  sys.puts('Now listening on port ' + port);
  app.listen(port);
}).call(this);
