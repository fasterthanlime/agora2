sys = require('sys')
sha1 = require('sha1')
express = require('express')

generateToken = (user) ->
  token = new Token({
    value: sha1(user + Math.random()) # yeah, there'll be dots, nobody cares
    user: user
    expiration: Date.now() + TOKEN_DURATION
  })
  token.save()
  token.value

sendTokenError = (res) ->
  res.send {
    result: 'error'
    error: 'Invalid token'
  }

isValidToken = (value, cb) ->
  Token.findOne { value: value }, (err, token) ->
    cb err || !token? || token.expiration < Date.now(), token

requireToken = (func) ->
  return (req, res) ->
    _args = arguments
    _this = this
    isValidToken req.param('token'), (valid) ->
      if valid
        sendTokenError res
      else
        func.apply( _this, _args )

app = express.createServer()

app.register('.html', {
  compile: (str, options) -> (locals) -> return str
});

app.use(express.static(__dirname + '/../frontend/'))
app.use(express.bodyParser());

dnode = require('dnode')
storage = require('./storage')
server = dnode(storage.ForumStorage)
server.listen app

app.get '/', (req, res) ->
  res.render 'index.html', { layout: false }

port = 3000
sys.puts('Now listening on port ' + port)

app.listen port
