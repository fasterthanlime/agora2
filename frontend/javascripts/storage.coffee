
@Agora.Storage = class Storage
  constructor: (@session, @remote) ->
    # TODO: restore freshness from local storage 
    # along with other saved data
    @lastUpdate = -1
    @tables = {}
    @callbacks = {}

    console.log 'Storage initialized with freshness', @lastUpdate
    if @lastUpdate == -1
      self = @
      @remote 'getSnapshot', (tableName, data) ->
        self.store(tableName, data)
        self.callbacks[tableName] ||= []
        self.callbacks[tableName].forEach (cb) ->
          cb(self.tables[tableName])
        self.callbacks[tableName] = []

  store: (tableName, data) ->
    query = TAFFY(data)
    @tables[tableName] = { present: true, query: query }
    console.log 'Just stored table', tableName, 'it has', query().count(), 'elements'

  get: (tableName, cb) ->
    console.log 'Retrieving table', tableName
    if (@tables.hasOwnProperty tableName)
      console.log 'Immediate retrieval of', tableName
      cb @tables[tableName]
    else
      console.log 'Queuing callback for retrieval of', tableName
      @callbacks[tableName] ||= []
      @callbacks[tableName].push cb

  save: ->
    console.log 'TODO: implement Storage::save'

