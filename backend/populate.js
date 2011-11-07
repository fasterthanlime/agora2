(function() {
  var Category, User, mongoose, schemas, sha1, sys;
  sys = require('sys');
  sha1 = require('sha1');
  mongoose = require('mongoose');
  schemas = require('./schemas');
  Category = mongoose.model('Category');
  User = mongoose.model('User');
  Category.remove({}, function() {
    new Category({
      slug: 'philo',
      title: 'Philosophico-théoriques',
      description: 'Débats, réflexions, partages d\'idées... sur tous les sujets profonds que le monde peut contenir.'
    }).save();
    new Category({
      slug: 'fufus',
      title: 'Le clan des fufus',
      description: 'Discussions sérieuses ou rigolotes sur tout ce qui concerne le clan des Fufus !'
    }).save();
    return new Category({
      slug: 'delirium',
      title: 'Délirium',
      description: 'Pour parler de tout et de rien, et même de n\'importe quoi ! Rigolades bienvenues.'
    }).save();
  });
  User.remove({}, function() {
    new User({
      username: "sylvain",
      nickname: "Obélix",
      email: "bigsylvain@gmail.com",
      joindate: Date.now(),
      posts: 0,
      avatar: "/stylesheets/avatar1.png",
      slogan: "Pardieu, c'est un inculte!",
      sha1: sha1("sylvain")
    }).save();
    return new User({
      username: "bluesky",
      nickname: "Loth",
      email: "amos@official.fm",
      joindate: Date.now(),
      posts: 0,
      avatar: "/stylesheets/avatar2.png",
      slogan: "Montjoie! Saint-Denis!",
      sha1: sha1("bluesky")
    }).save();
  });
  sys.puts('Done populating!');
}).call(this);
