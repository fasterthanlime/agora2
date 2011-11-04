sys = require('sys')
express = require('express')
mongoose = require('mongoose')
schemas = require('./schemas')

app = express.createServer()

app.register('.html', {
  compile: (str, options) -> (locals) -> return str
});
app.use(express.static(__dirname + '/../'))

app.get '/', (req, res) ->
  res.render 'index.html', { layout: false }

app.get '/categories', (req, res) ->
  Category = mongoose.model('Category')
  Category.find {}, (err, cats) ->
    res.send JSON.stringify(cats)

port = 3000
sys.puts('Now listening on port ' + port)

app.listen port
