sys = require('sys')
express = require('express')
mongoose = require('mongoose')
schemas = require('./schemas')

app = express.createServer()

app.get '/', (req, res) ->
  Category = mongoose.model('Category')
  Category.find {}, (err, cats) ->
    res.send 'Categories = ' + JSON.stringify(cats)

port = 3000
sys.puts('Now listening on port ' + port)

app.listen port
