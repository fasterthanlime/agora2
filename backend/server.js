(function() {
  var Category, Post, TOKEN_DURATION, Thread, Token, User, app, express, generate_token, mongoose, port, schemas, sha1, sys;
  sys = require('sys');
  sha1 = require('sha1');
  express = require('express');
  mongoose = require('mongoose');
  schemas = require('./schemas');
  Thread = mongoose.model('Thread');
  Post = mongoose.model('Post');
  Category = mongoose.model('Category');
  User = mongoose.model('User');
  Token = mongoose.model('Token');
  TOKEN_DURATION = 86400000;
  generate_token = function(user) {
    var token;
    token = new Token({
      value: sha1(user + Math.random()),
      user: user,
      expiration: Date.now() + TOKEN_DURATION
    });
    token.save();
    return token.value;
  };
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
      return res.send(cats);
    });
  });
  app.get('/category/:slug', function(req, res) {
    return Category.findOne({
      slug: req.params.slug
    }, function(err, cat) {
      return res.send(cat);
    });
  });
  app.get('/thread/:tid', function(req, res) {
    return Thread.findById(req.params.tid, function(err, thread) {
      return res.send(thread);
    });
  });
  app.post('/new-thread', function(req, res) {
    var post, thread;
    thread = new Thread({
      username: req.body.username,
      title: req.body.title
    });
    post = new Post({
      username: req.body.username,
      source: req.body.source,
      date: Date.now()
    });
    post.save();
    thread.posts.push(post);
    thread.save();
    Category.findById(req.body.category, function(err, category) {
      category.threads.push(thread);
      return category.save();
    });
    User.findOne({
      username: req.body.username
    }, function(err, user) {
      user.posts += 1;
      return user.save();
    });
    return res.send({
      result: 'success',
      id: thread._id
    });
  });
  app.post('/post-reply', function(req, res) {
    return Thread.findById(req.body.tid, function(err, thread) {
      var post;
      post = new Post({
        username: req.body.username,
        source: req.body.source,
        date: Date.now()
      });
      post.save();
      thread.posts.push(post);
      thread.save();
      User.findOne({
        username: req.body.username
      }, function(err, user) {
        user.posts += 1;
        return user.save();
      });
      return res.send({
        result: 'success',
        date: post.date
      });
    });
  });
  app.post('/login', function(req, res) {
    return User.findOne({
      username: req.body.login
    }, function(err, user) {
      if (err) {
        return res.send({
          result: 'not found'
        });
      } else {
        if (sha1(req.body.password) === user.sha1) {
          return res.send({
            result: 'success',
            session_token: generate_token(user.username),
            user: user
          });
        } else {
          return res.send({
            result: 'failure',
            provided: sha1(req.body.password),
            stored: user.sha1
          });
        }
      }
    });
  });
  app.get('/user/:username', function(req, res) {
    return User.findOne({
      username: req.params.username
    }, function(err, user) {
      if (err) {
        return res.send({
          result: 'not found'
        });
      } else {
        return res.send(user);
      }
    });
  });
  app.post('/logout', function(req, res) {
    return Token.remove({
      value: req.body.token
    }, function(err, token) {
      return res.send({
        result: 'success'
      });
    });
  });
  port = 3000;
  sys.puts('Now listening on port ' + port);
  app.listen(port);
}).call(this);
