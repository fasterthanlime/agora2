
@database =
  Users: [
    {
      _id: 'user01'
      username: 'bluesky'
      nickname: 'Loth'
      email: 'amos@official.fm'
      joindate: 0
      posts: 2
      slogan: 'Whatever'
      avatar: ''
    },
    {
      _id: 'user02'
      username: 'romac'
      nickname: 'Romac'
      email: 'romac@official.fm'
      joindate: 0
      posts: 1
      slogan: '6 colors'
      avatar: ''
    }
  ],
  Posts: [
    {
      _id: 'post01'
      userId: 'user01'
      source: 'C\'est moi le premier, yay o/'
      date: 0
    },
    {
      _id: 'post02'
      userId: 'user02'
      source: 'Congrats, buddy !'
      date: 0
    },
    {
      _id: 'post03'
      userId: 'user01'
      source: 'Thanks, dude !'
      date: 0
    }
  ],
  Threads: [
    {
      _id: 'thread01'
      title: 'Pour être le premier, c\'est ici !'
      posts: [ 'post01', 'post02' ]
    },
    {
      _id: 'thread02'
      title: 'Les news de la semaine - #1'
      posts: [ 'post03' ]
    },
    {
      _id: 'thread03'
      title: 'Comment dire non à sa mère'
      posts: [  ]
    }
  ],
  Categories: [
    {
      name: 'Général'
      description: 'Tout ce qui n\'a pas d\'importance.'
      threads: [ 'thread01', 'thread02' ]
    },
    {
      name: 'Psycho'
      description: 'C\'est dans ta tête.'
      threads: [ 'thread03' ]
    }
  ]