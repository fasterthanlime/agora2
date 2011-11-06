(function() {
  var Category, Post, Schema, Thread, Token, User, mongoose;
  mongoose = require('mongoose');
  mongoose.connect('mongodb://localhost/agora');
  Schema = mongoose.Schema;
  User = new Schema({
    username: String,
    nickname: String,
    email: String,
    joindate: Number,
    slogan: String,
    avatar: String,
    sha1: String
  });
  mongoose.model('User', User);
  Post = new Schema({
    username: String,
    source: String,
    date: Number
  });
  mongoose.model('Post', Post);
  Thread = new Schema({
    title: String,
    posts: [Post]
  });
  mongoose.model('Thread', Thread);
  Category = new Schema({
    name: String,
    description: String,
    threads: [Thread]
  });
  mongoose.model('Category', Category);
  Token = new Schema({
    value: String,
    username: String,
    expiration: Number
  });
  mongoose.model('Token', Token);
}).call(this);
