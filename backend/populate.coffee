sys = require('sys')
sha1 = require('sha1')
mongoose = require('mongoose')
schemas = require('./schemas')

# Add a few categories
Category = mongoose.model('Category')
Thread = mongoose.model('Thread')
Post = mongoose.model('Post')
User = mongoose.model('User')

Category.remove {}, ->
  philo = new Category({
    slug: 'philo',
    title: 'Philosophico-théoriques',
    description: 'Débats, réflexions, partages d\'idées... sur tous les sujets profonds que le monde peut contenir.'  
  })
  philo.save()

  fufus = new Category({
    slug: 'fufus',
    title: 'Le clan des fufus',
    description: 'Discussions sérieuses ou rigolotes sur tout ce qui concerne le clan des Fufus !'  
  })
  fufus.save()

  delirium = new Category({
    slug: 'delirium',
    title: 'Délirium',
    description: 'Pour parler de tout et de rien, et même de n\'importe quoi ! Rigolades bienvenues.'  
  })
  delirium.save()

  User.remove {}, ->
    sylvain = new User({
      username: "sylvain"
      nickname: "Obélix"
      email: "bigsylvain@gmail.com"
      joindate: Date.now()
      posts: 0
      avatar: "/stylesheets/avat1.png"
      slogan: "Pardieu, c'est un inculte!"
      sha1: sha1("sylvain")
    })
    sylvain.save()

    bluesky = new User({
      username: "bluesky"
      nickname: "Loth"
      email: "amos@official.fm"
      joindate: Date.now()
      posts: 0
      avatar: "/stylesheets/avat2.png"
      slogan: "Montjoie! Saint-Denis!"
      sha1: sha1("bluesky")
    })
    bluesky.save()

    romac = new User({
      username: "romac"
      nickname: "Romac"
      email: "romain.ruetschi@gmail.com"
      joindate: Date.now()
      posts: 0
      avatar: "/stylesheets/avat3.png"
      slogan: "Un bon eskimo est un eskimo maure."
      sha1: sha1("romac")
    })
    romac.save()

    Thread.remove {}, ->
      Post.remove {}, ->
        thread1 = new Thread({
          title: 'Les roses sont-elles rouges?' 
        })

        post11 = new Post({
          user: bluesky._id
          source: "C'est vrai quoi?"   
          date: Date.now()
        })
        post11.save()
        thread1.posts.push post11._id

        post12 = new Post({
          user: romac._id
          source: "Dude, I have no idea"
          date: Date.now()
        })
        post12.save()
        thread1.posts.push post12._id

        post13 = new Post({
          user: sylvain._id
          source: "YOBAAAAAAAA!"
          date: Date.now()
        })
        post13.save()
        thread1.posts.push post13._id

        thread1.save()
        philo.threads.push thread1._id
        philo.save()

        sys.puts('Done populating!')

