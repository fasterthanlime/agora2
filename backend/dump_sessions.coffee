sys = require('sys')
mongoose = require('mongoose')
schemas = require('./schemas')

Token = mongoose.model('Token')

Token.find {}, (err, tokens) ->
  tokens.forEach (token) ->
    sys.puts(JSON.stringify(token))
  process.exit(0)
