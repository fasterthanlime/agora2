
# TODO: extract common useful methods in a common file
arrayWithout = (array, value) ->
  newArray = []
  for i in [0..array.length]
    if array[i] != value
      newArray.push array[i]
  # console.log 'array', array, 'without', value, 'is', newArray
  newArray


@Agora.Storage = class Storage
  constructor: (@session, @remote) ->
    # TODO: restore freshness from local storage 
    # along with other saved data
    @lastUpdate = -1
    @tables = {}
    @callbacks = []

    console.log 'Storage initialized with freshness', @lastUpdate
    @refresh()

  refresh: ->
    console.log "Refreshing."
    if @lastUpdate == -1
      self = @
      @remote 'getSnapshot', (data) ->
        console.log 'Received DB snapshot from server:', data
        for own key in data.types
          self.tables[key] = TAFFY(data[key])
        while self.callbacks.length > 0
          cb = self.callbacks.shift()
          cb self.tables
        self.lastUpdate = Date.now()
        console.log 'Storage updated at', Agora.utils.formatDate(self.lastUpdate)

  get: (cb) ->
    if @lastUpdate == -1
      console.log 'Deferring usage of database until it is loaded'
      @callbacks.push cb
    else
      cb @tables

  addPost: (postData, cb) ->
    self = @
    console.log 'Sending post', postData
    @remote 'addPost', [postData, (post) ->
      self.onPost post
      cb post
    ]

  deletePost: (info) ->
    @remote 'deletePost', [info]

  onPost: (post) ->
    console.log 'On post', post
    @tables.Post.insert(post)
    threadQ = @tables.Thread({ _id: post.thread })
    thread = threadQ.first()
    console.log 'Got thread', thread
    thread.posts.push post._id
    threadQ.update thread

  onDeletePost: (info) ->
    console.log 'On delete post', info.postID
    thread = @tables.Thread({ _id: info.threadID }).first()
    thread.posts = arrayWithout(thread.posts, info.postID)
    @tables.Post({ _id: info.postID }).remove()
    console.log 'Post', info.postID, 'removed from DB'

  save: ->
    console.log 'TODO: implement Storage::save'

