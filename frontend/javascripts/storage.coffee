
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

  addPost: (post) ->
    console.log 'Adding post', post
    @remote 'addPost', [post, (date) ->
      console.log 'Server date =', date
    ]

  save: ->
    console.log 'TODO: implement Storage::save'

