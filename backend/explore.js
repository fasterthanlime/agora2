(function() {
  var Thread, mongoose, schemas, sys;
  mongoose = require('mongoose');
  schemas = require('./schemas');
  sys = require('sys');
  Thread = mongoose.model('Thread');
  Thread.find({}, function(err, threads) {
    return sys.puts(JSON.stringify(threads));
  });
}).call(this);
