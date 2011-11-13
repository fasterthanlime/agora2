
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

  addPost: (postData) ->
    self = @
    console.log 'Sending post', postData
    @remote 'addPost', [postData, (post) ->
      self.onPost post
    ]

  onPost: (post) ->
    console.log 'On post', post
    @tables.Post.insert(post)
    threadQ = @tables.Thread({ _id: post.thread })
    thread = threadQ.first()
    console.log 'Got thread', thread
    thread.posts.push post._id
    threadQ.update thread

  save: ->
    console.log 'TODO: implement Storage::save'

