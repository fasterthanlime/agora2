
pad = (number) ->
  if number < 10 
    '0' + number
  else
    '' + number

formatDate = do ->
  months = [
    "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
    "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
  ]
  (timestamp) ->
    date = new Date(timestamp)
    pad(date.getDate()) + " " +
    months[date.getMonth()] + " " + 
    date.getFullYear() + " à " + 
    pad(date.getHours()) + ":" + 
    pad(date.getMinutes()) + ":" + 
    pad(date.getSeconds())

@utils = { formatDate }
