(function() {
  var Token, mongoose, schemas, sys;
  sys = require('sys');
  mongoose = require('mongoose');
  schemas = require('./schemas');
  Token = mongoose.model('Token');
  Token.find({}, function(err, tokens) {
    tokens.forEach(function(token) {
      return sys.puts(JSON.stringify(token));
    });
    return process.exit(0);
  });
}).call(this);
