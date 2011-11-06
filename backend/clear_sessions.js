(function() {
  var Token, mongoose, schemas, sys;
  sys = require('sys');
  mongoose = require('mongoose');
  schemas = require('./schemas');
  Token = mongoose.model('Token');
  Token.remove({}, function() {
    sys.puts('All sessions cleared');
    return process.exit(0);
  });
}).call(this);
