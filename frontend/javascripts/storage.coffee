
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
        console.log 'Got snapshot', data
        for own key in data.types
          self.store key, data[key]
        while self.callbacks.length > 0
          cb = self.callbacks.shift()
          cb self.tables
        self.lastUpdate = Date.now()
        console.log 'Storage updated at', Agora.utils.formatDate(self.lastUpdate)

  store: (tableName, data) ->
    @tables[tableName] = TAFFY(data)
    console.log 'Just stored table', tableName

  get: (cb) ->
    if @lastUpdate == -1
      console.log 'Need database that is not ready yet, queuing for later'
      @callbacks.push cb
    else
      console.log 'Need database, it is ready, let us go!. lastUpdate = ', @lastUpdate, ', tables = ', @tables
      cb @tables

  save: ->
    console.log 'TODO: implement Storage::save'

