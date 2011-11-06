
sys = require('sys')
mongoose = require('mongoose')
schemas = require('./schemas')

Token = mongoose.model('Token')

Token.remove {}, ->
  sys.puts('All sessions cleared')
  process.exit(0)
