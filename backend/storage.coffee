sha1 = require('sha1')
mongoose = require('mongoose')
schemas = require('./schemas')

Thread = mongoose.model('Thread')
Post = mongoose.model('Post')
Category = mongoose.model('Category')
User = mongoose.model('User')
Token = mongoose.model('Token')

TOKEN_DURATION = 86400000

validate = (object, fields, cb) ->
  fields.forEach (field) ->
    if !(cb.hasOwnProperty field)
      cb('Missing property ' + field)
      return
  cb()

# Probably an abomination, but works nicely to
# send any object via dnode
sanitize = (object, blacklist) ->
  newObject = JSON.parse JSON.stringify object
  if blacklist then blacklist.forEach (banned) ->
      delete newObject[banned]
  newObject

without = (object, blacklist = []) ->
  newObject = JSON.parse JSON.stringify object
  blacklist.forEach (banned) ->
    if ( index = newObject.indexOf banned ) != 1
      newObject.splice index, 1
  newObject

generateToken = (user) ->
  token = new Token({
    value: sha1(user + Math.random())
    user: user
    expiration: Date.now() + TOKEN_DURATION
  })
  token.save()
  token.value

class Session
  constructor: (user, @listener) ->
    @user = sanitize(user, ['sha1'])
    @token = generateToken @user.username
    console.log @listener
    @notify = @listener.notify

  getRemote: ->
    session = @
    return (name, args) ->
      if args instanceof Array
        session[name].apply(session, args)
      else
        session[name].apply(session, [args])

  logout: ->
    token = @token
    Token.remove { value: @token }, (err) ->
      console.log 'Session with token ', token, ' logged out.'
    store.removeSession @

  addPost: (postData, cb) ->
    self = @
    postData.date = Date.now()
    post = new Post(postData)
    post.save()
    console.log 'Adding post', post

    Thread.findById postData.thread, (err, thread) ->
      thread.posts.push(post)  
      console.log 'Adding to thread', thread.title
      thread.save()

    cb sanitize(post)
    store.notify(@token, 'onPost', sanitize(post))

  getSnapshot: (cb) ->
    store.getSnapshot @token, cb

class ForumStorage
  constructor: ->
    @sessions = []

  addSession: (session) ->
    console.log 'New session with token ', session.token
    @sessions.push session

  removeSession: (session) ->
    @sessions = without(@sessions, [session])

  notify: (token, method, args) ->
    @sessions.forEach (session) ->
      if session.token != token
        # RPC on other connected clients, ftw
        console.log 'notify -> ', session.user.username, ' of ', method, args
        try
          session.notify(method, args)
        catch error
          console.log 'Error while notifying ', session.token, error

  getSnapshot: (token, cb) ->
    # TODO: verify token
    User.find {}, (err, users) ->
      Category.find {}, (err, categories) ->
        Thread.find {}, (err, threads) ->
          Post.find {}, (err, posts) ->
            cb {
              types: ['User', 'Category', 'Thread', 'Post']
              User: sanitize(users)
              Category: sanitize(categories)
              Thread: sanitize(threads)
              Post: sanitize(posts)
            }

store = new ForumStorage()

module.exports = {

  store: store 
  Gateway: {
    # storage, of type ForumStorage
    resume: (token, notify, cb) ->
      console.log 'Trying to resume from token ', token
      found = false
      store.sessions.forEach (session) ->
        if session.token == token
          console.log 'Found session!'
          session.notify = notify
          cb {
            status: 'success'
            remote: session.getRemote()
          }
          found = true
      if !found
        console.log 'Not found! Logging poor fucker off'
        cb {
          status: 'failure'
        }


    login: (username, password, listener) ->
      # TODO: find User in database, associate with session
      console.log 'Attempted login with username ', username
      User.findOne { username: username }, (err, user) ->
        if (err || !user)
          console.log 'User not found: ', username, ' error: ', err
          listener.notify 'onLogin', {
            status: 'error'
            reason: 'User not found'
          }
        else
          session = new Session(user, listener)
          store.addSession session
          listener.notify 'onLogin', {
            status: 'success'
            session: sanitize(session, ['listener'])
            remote: session.getRemote()
          }
  }

}


