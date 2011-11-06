sys = require('sys')
express = require('express')
mongoose = require('mongoose')
schemas = require('./schemas')

Thread = mongoose.model('Thread')
Post = mongoose.model('Post')
Category = mongoose.model('Category')

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
    res.send JSON.stringify cats

app.get '/category/:slug', (req, res) ->
  Category.findOne {slug: req.params.slug}, (err, cat) ->
    res.send JSON.stringify cat

app.get '/thread/:tid', (req, res) ->
  Thread.findById req.params.tid, (err, thread) ->
    res.send JSON.stringify thread

app.post '/new-thread', (req, res) ->
  thread = new Thread({username: req.body.username, title: req.body.title})
  post = new Post({
    username: req.body.username
    source: req.body.source
  })
  post.save()
  thread.posts.push(post)
  thread.save()
  category = Category.findById req.body.category, (err, category) ->
    category.threads.push(thread)
    category.save()
  res.send JSON.stringify {result: 'success', id: thread._id}

port = 3000
sys.puts('Now listening on port ' + port)

app.listen port
