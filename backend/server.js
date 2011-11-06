(function() {
  var Category, Post, Thread, app, express, mongoose, port, schemas, sys;
  sys = require('sys');
  express = require('express');
  mongoose = require('mongoose');
  schemas = require('./schemas');
  Thread = mongoose.model('Thread');
  Post = mongoose.model('Post');
  Category = mongoose.model('Category');
  app = express.createServer();
  app.register('.html', {
    compile: function(str, options) {
      return function(locals) {
        return str;
      };
    }
  });
  app.use(express.static(__dirname + '/../'));
  app.use(express.bodyParser());
  app.get('/', function(req, res) {
    return res.render('index.html', {
      layout: false
    });
  });
  app.get('/categories', function(req, res) {
    return Category.find({}, ['slug', 'title', 'description', '_id'], function(err, cats) {
      return res.send(JSON.stringify(cats));
    });
  });
  app.get('/category/:slug', function(req, res) {
    return Category.findOne({
      slug: req.params.slug
    }, function(err, cat) {
      return res.send(JSON.stringify(cat));
    });
  });
  app.get('/thread/:tid', function(req, res) {
    return Thread.findById(req.params.tid, function(err, thread) {
      return res.send(JSON.stringify(thread));
    });
  });
  app.post('/new-thread', function(req, res) {
    var category, post, thread;
    thread = new Thread({
      username: req.body.username,
      title: req.body.title
    });
    post = new Post({
      username: req.body.username,
      source: req.body.source
    });
    post.save();
    thread.posts.push(post);
    thread.save();
    category = Category.findById(req.body.category, function(err, category) {
      category.threads.push(thread);
      return category.save();
    });
    return res.send(JSON.stringify({
      result: 'success',
      id: thread._id
    }));
  });
  app.post('/post-reply', function(req, res) {
    return Thread.findById(req.body.tid, function(err, thread) {
      var post;
      post = new Post({
        username: req.body.username,
        source: req.body.source
      });
      post.save();
      thread.posts.push(post);
      thread.save();
      return res.send(JSON.stringify({
        result: 'success'
      }));
    });
  });
  port = 3000;
  sys.puts('Now listening on port ' + port);
  app.listen(port);
}).call(this);
