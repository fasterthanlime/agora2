mongoose = require('mongoose')
schemas = require('./schemas')

Thread = mongoose.model('Thread')
Post = mongoose.model('Post')
Category = mongoose.model('Category')
User = mongoose.model('User')
Token = mongoose.model('Token')

TOKEN_DURATION = 86400000

validate: (object, fields, cb) ->
  fields.forEach (field) ->
    if !(cb.hasOwnProperty field)
      cb('Missing property ' + field)
      return
  cb()

exports.ForumStorage = {
  clients: []

  registerClient: (client) ->
    clients.push client

  login: (user, password, cb) ->
    console.log 'Attempted login with user ', user
    cb({ user: user, joke: 'Why did cancer cross the road? To get to the other lung!' })

  startThread: (_thread, _post, cb) ->
    validate _thread, ['categoryId', 'title'], (err) ->
      if (err)
        console.log 'Received invalid thread object ', thread, ' - error = ', err
      else
        thread = new Thread(_thread)
        thread.save()
        cb(thread._id)
        reply(thread._id, _post)
        notify('newThread', [thread])

  reply: (threadId, _post, cb) ->
    validate _post, ['threadId', 'userId', 'source'], (err) ->
      if (err)
        console.log 'Received invalid post reply ', thread, ' - error = ', err
      else
        post = new Post(_post)
        post.save()
        cb(post._id)
        notify('postReply', [threadId, post])
} 


