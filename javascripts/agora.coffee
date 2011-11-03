# Simple sammy test in CS :)

(Sammy '#main', ->
  @get '#/', context ->
    @$elements().html('OH HAI THERE')
).run
