(function() {
  var Category, mongoose, schemas, sys;
  sys = require('sys');
  mongoose = require('mongoose');
  schemas = require('./schemas');
  Category = mongoose.model('Category');
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
  sys.puts('Done populating!');
}).call(this);
