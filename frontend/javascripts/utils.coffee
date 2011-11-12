
pad = (number) ->
  ((number < 10) ? '0' : '') + number

showdown = new Showdown.converter()

@utils = {
  md2html: (source) ->
    showdown.makeHtml(source)

  allDefined: (object, fields) ->
    result = true
    fields.forEach (field) ->
      if !(object.hasOwnProperty field)
        result = false
    result

  formatDate: do ->
    months = [ # TODO i18n
      "Janvier", "Février", "Mars",
      "Avril", "Mai", "Juin",
      "Juillet", "Août", "Septembre",
      "Octobre", "Novembre", "Décembre"
    ]
    (timestamp) ->
      date = new Date(timestamp)
      pad(date.getDate()) + " " +
      months[date.getMonth()] + " " + 
      date.getFullYear() + " à " + # TODO i18n
      pad(date.getHours()) + ":" + 
      pad(date.getMinutes()) + ":" + 
      pad(date.getSeconds())
}
