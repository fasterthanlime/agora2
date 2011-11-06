sys = require('sys')
sha1 = require('sha1')
express = require('express')
mongoose = require('mongoose')
schemas = require('./schemas')

Thread = mongoose.model('Thread')
Post = mongoose.model('Post')
Category = mongoose.model('Category')
User = mongoose.model('User')
Token = mongoose.model('Token')

TOKEN_DURATION = 86400000

generate_token = (user) ->
  token = new Token({
    value: sha1(user + Math.random()) # yeah, there'll be dots, nobody cares
    user: user
    expiration: Date.now() + TOKEN_DURATION
  })
  token.save()
  token.value

app = express.createServer()

app.register('.html', {
  compile: (str, options) -> (locals) -> return str
});

app.use(express.static(__dirname + '/../'))
app.use(express.bodyParser());

app.get '/', (req, res) ->
  res.render 'index.html', { layout: false }

app.get '/categories', (req, res) ->
  Category.find {}, ['slug', 'title', 'description', '_id'], (err, cats) ->
    res.send cats

app.get '/category/:slug', (req, res) ->
  Category.findOne { slug: req.params.slug }, (err, cat) ->
    res.send cat

app.get '/thread/:tid', (req, res) ->
  Thread.findById req.params.tid, (err, thread) ->
    res.send thread

app.post '/new-thread', (req, res) ->
  thread = new Thread({ username: req.body.username, title: req.body.title })
  post = new Post({
    username: req.body.username
    source: req.body.source
    date: Date.now()
  })
  post.save()
  thread.posts.push(post)
  thread.save()
  category = Category.findById req.body.category, (err, category) ->
    category.threads.push(thread)
    category.save()
  res.send { result: 'success', id: thread._id }

app.post '/post-reply', (req, res) ->
  Thread.findById req.body.tid, (err, thread) ->
    post = new Post({
      username: req.body.username
      source: req.body.source
      date: Date.now()
    })
    post.save()
    thread.posts.push(post)
    thread.save()
    res.send { result: 'success' }

app.post '/login', (req, res) ->
  User.findOne { username: req.body.login }, (err, user) ->
    if err
      res.send { result: 'not found' }
    else
      if sha1(req.body.password) == user.sha1
        res.send { result: 'success', session_token: generate_token(user.username), user: user }
      else
        res.send { result: 'failure', provided: sha1(req.body.password), stored: user.sha1 }

app.post '/logout', (req, res) ->
  Token.remove { value: req.body.token }, (err, token) ->
    # Well if it wasn't there in the first place, everybody wins!
    res.send { result: 'success' }

port = 3000
sys.puts('Now listening on port ' + port)

app.listen port
