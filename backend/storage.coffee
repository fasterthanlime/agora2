sha1 = require('sha1')
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

generateToken = (user) ->
  token = new Token({
    value: sha1(user + Math.random()) # yeah, there'll be dots, nobody cares
    user: user
    expiration: Date.now() + TOKEN_DURATION
  })
  token.save()
  token.value


class Session
  constructor: (@user) ->
    @token = generateToken @user

class ForumStorage
  constructor: ->
    @sessions = []

  addSession: (session) ->
    console.log 'New session: ', session
    @sessions.push session

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

module.exports = {
 
  ForumStorage: ForumStorage 
  Gateway: {
    # storage, of type ForumStorage

    login: (user, password, onLogged) ->
      # TODO: find User in database, associate with session
      console.log 'Attempted login with user ', user
      session = new Session (user)
      @storage.addSession session
      onLogged session
  }

} 


