(function() {
  var app, express, mongoose, port, schemas, sys;
  sys = require('sys');
  express = require('express');
  mongoose = require('mongoose');
  schemas = require('./schemas');
  app = express.createServer();
  app.get('/', function(req, res) {
    var Category;
    Category = mongoose.model('Category');
    return Category.find({}, function(err, cats) {
      return res.send('Categories = ' + JSON.stringify(cats));
    });
  });
  port = 3000;
  sys.puts('Now listening on port ' + port);
  app.listen(port);
}).call(this);
