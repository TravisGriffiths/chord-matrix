window.utilities = {}

################
# cleanNumber takes a number and returns a rounded string with a magnitude letter
# i.e. 6000000 -> "6M"
################
cleanNumber = (number, locale) ->
  locale ?= 'us' #assume US if locale is not specified
  symbols = utilities.localInfo[locale]
  number = Number(number) #in case we were passed a String
  sign = ""
  if number < 0
    sign = "-"
    number *= -1
  magnitude = ["", "K", "M", "B", "T", "Q"] #Note numbers of 1 QUINTILLION (10^18 in short scale) or more will fail
  mag_index = 0
  while(number >= 1000)
    number /= 1000
    mag_index += 1
  working = String(number)
  radix = working.indexOf('.');
  if(radix < 0)
    radix = false
  if(radix && (working.length - radix > 2))
    radix_cutoff = 3
    working = working.substring(0, radix + radix_cutoff)
  result = (working + magnitude[mag_index])
  result.replace(".", symbols.radix)
  result = sign + result

window.utilities['cleanNumber'] = cleanNumber

cleanNumberDefaultLocale = (number) ->
  cleanNumber(number)

window.utilities['cleanNumberDefaultLocale'] = cleanNumberDefaultLocale


################
# cleanByteCount takes a number and returns a string representing the byte count
# i.e. 1024 -> "1KB"
################
cleanByteCount = (number) ->
  number = Number(number) #in case we were passed a String
  sign = ""
  if number < 0 #Negative bytes makes sense in a few cases like deltas
    sign = "-"
    number *= -1
  magnitude = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB"] #Note: byte counts in excess of 999 Zetabytes will fail
  mag_index = 0
  while(number >= 1000)
    number /= 1000
    mag_index += 1
  working = String(number)
  radix = working.indexOf('.');
  if(radix < 0)
    radix = false
  if(radix && (working.length - radix > 2))
    radix_cutoff = 3
    working = working.substring(0, radix + radix_cutoff)
  result = (sign + working + magnitude[mag_index])

window.utilities['cleanByteCount'] = cleanByteCount

###############
# localInfo is simply a object hash with 2 char location strings, i.e. 'us', 'br' with values
# of a simple hash giving, currency, radix and seperator strings
###############
localInfo = {
'us': {
'currency': '$',
'radix': '.',
'seperator': ','
},
'br': {
'currency': 'R$',
'radix': ',',
'seperator': '.'
},
'eu': {
'currency': '€',
'radix': ',',
'seperator': '.'
},
}
window.utilities['localInfo'] = localInfo

###############
# toCurrency takes a number and optional localization string and returns a currency string
# i.e. 43245.25125 => "$43,245.25" OR "R$43.245,35"
# additionally you may pass a boolean to turn the seperator commas on and off
# NOTE: When passing a locale string, the seperator boolean is required
###############
toCurrency = (number, use_seperators, locale) ->
  locale ?= 'us'
  symbols = utilities.localInfo[locale]
  sign = ""
  if number < 0
    sign = "-"
    number *= -1
  result = sign + symbols.currency + toHumanNumber(number, [use_seperators, true, locale])

window.utilities['toCurrency'] = toCurrency

toCurrencyDefaultLocale = (number) ->
  toCurrency(number)

window.utilities['toCurrencyDefaultLocale'] = toCurrencyDefaultLocale

###############
# toHumanNumber takes a number and optional localization string and returns a seperator
# deliniated string, i.e. 123445676.00 => "123,445,676.00" or
# 1234567.89 -> 1.234.567,89" if 'eu' or 'br' is passed as a localization string
###############
toHumanNumber = (number, args) ->
  #Basic number checks and cleaning
  number = Number(number) #in case we have a string
  sign = ""
  if number < 0  #check for negative
    sign = "-"
    number *= -1
  #args => [use_seperators, decimal, locale]
  args ?= []
  use_seperators = if args[0]? then args[0] else true #Use seperators by default
  decimal = if args[1]? then args[1] else false #Cast to Int by default
  locale = if args[2]? then args[2] else 'us' #Use US location by default
  symbols = utilities.localInfo[locale]
  if number >= 1000000000 #Make a number >= 1 Billion readable by using cleanNumber format i.e. "1B"
    cleanNumber(number, locale)
  else
    decimals = if decimal then parseFloat(Number(number)).toFixed(2).split(".")[1] else ""
    number = parseInt(Number(number))
    blocks = []
    result = ""
    while(number >= 1000)
      if (number % 1000) < 100 #going to get a < 3 digit number
        block = String(number % 1000)
        while block.length < 3
          block = '0' + block
        blocks.push(block)
      else
        blocks.push(number % 1000)
      number = Math.floor(number/1000)
    blocks.push(number)
    separator_to_use = if use_seperators then symbols.seperator else ''
    result += blocks.reverse().join(separator_to_use)
    result += (symbols.radix + decimals) if decimal
    result = (sign + result)
    result

window.utilities['toHumanNumber'] = toHumanNumber

###############
# toHumanFloat is just a wrapper for toHumanNumber with the float decimals set to true thus:
# 1234567.345678 -> 1,234,567.34"
###############
toHumanFloat = (number, locale) ->
  toHumanNumber(number, [true, true, locale])

window.utilities['toHumanFloat'] = toHumanFloat

###############
# toHumanInt is just a wrapper for toHumanNumber with the float decimals set to false thus:
# 1234567.345678 -> 1,234,567"
###############
toHumanInt = (number, locale) ->
  toHumanNumber(number, [true, false, locale])

window.utilities['toHumanInt'] = toHumanInt

###############
# toBoolean changes true/false to Yes/No
###############
toBoolean = (value) ->
  if value then "Yes" else "No"

window.utilities['toBoolean'] = toBoolean

###############
# toDate produces a javascript date from an object which looks like this:
# { year: 2012, month: 2, day: 1}
###############
toDate = (dateObj) ->
  if typeof(dateObj) is "string"
    new Date(dateObj)
  else
    new Date(dateObj.year, dateObj.month - 1, dateObj.day)

window.utilities['toDate'] = toDate

###############
# toDateTime produces a javascript date from a date string
# { year: 2012, month: 2, day: 1}
###############
toDateTime = (dateTimeObj) ->
  new Date(dateTimeObj)

window.utilities['toDateTime'] = toDateTime


###############
# Prints a readable date
###############
formatDate = (dateObj, format) ->
  format ?= "yyyy/MM/dd"
  toDate(dateObj).toString(format)

window.utilities['formatDate'] = formatDate

###
  GetAxisScale takes an array and returns the best match in terms of a scale that evenly spaces the points given
  Examples:
    [1,2,3,4,5] -> "linear"
    [1, 10, 100] -> "logrithmic"
###
getAxisScale = (axis) ->
  axis = _.toArray(axis)
  line_scale = d3.scale.linear()
  log_scale = d3.scale.log()
  line_map = _.map(axis, (point) ->
    line_scale(point)
  )
  log_map = _.map(axis, (point) ->
    log_scale(point)
  )
  # English: Use the scale for which the Standard Diviation of the distance
  # between points is the least, i.e. most even distribution of points.
  if getSD(getSpaces(line_map)) > getSD(getSpaces(log_map)) then "log" else "linear"

window.utilities['getAxisScale'] = getAxisScale

###
  getSD returns the standard deviation in for numbers in an array
###
getSD = (set) ->
  return -1 if not _.isArray(set) or set.length == 0
  mean = d3.mean(set)
  return -1 unless _.isNumber(mean)
  offsets = []
  for item in set
    offsets.push(Math.pow((Number(item) - mean), 2))
  Math.pow((d3.sum(offsets) / set.length), 0.5)

window.utilities['getSD'] = getSD

###
  getSpaces is a method for getting the spaces between array values [1, 2, 3] -> [1, 1]
###
getSpaces = (set) ->
  set = set.sort() #assume array
  result_set = []
  previous = null
  for item in set
    result_set.push(item - previous) if previous
    previous = item
  result_set

window.utilities['getSpaces'] = getSpaces

###
  Counter returns a simple function that after setting a start point will increment by one for each time it is called.
  c = utilities.counter(0) -> returns function
  c() -> 0
  c() -> 1
  c() -> 2
###
counter = (start_number) ->
  start_number -= 1 #increment will happen first call
  ->
    start_number += 1

window.utilities['counter'] = counter

###
  Make Unique ID returns miliseconds since epoc + a random number string to guantee uniqueness
###
getUniqueID = ->
  c = counter(0)
  d = new Date()
  t = d.getTime()
  String(Math.floor(Math.random(c()) * 100000)) + String(t)

window.utilities['getUniqueID'] = getUniqueID



###
  Simple testing function returns a random square matrix
###
getSquareMatrix = (size) ->
  c = counter(0)
  cols = []
  for col in [1..size]
    row = []
    for record in [1..size]
      row.push(Math.floor(Math.random(c()) * 1000))
    cols.push(row)
  cols

window.utilities['getSquareMatrix'] = getSquareMatrix

sortNumbers = (a, b) ->
  if Number(a) == Number(b)
    return 0
  else
    if Number(a) < Number(b) then return -1 else return 1

window.utilities.sortNumbers = sortNumbers

toPercentage = (float) ->
  utilities.toHumanFloat(float *= 100) + "%"

window.utilities.toPercentage = toPercentage
