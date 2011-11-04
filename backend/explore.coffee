mongoose = require('mongoose')
schemas = require('./schemas')
sys = require('sys')

Thread = mongoose.model('Thread')
Thread.find {}, (err, threads) ->
        sys.puts(JSON.stringify(threads))
