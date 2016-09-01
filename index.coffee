querystring = require 'querystring'
cheerio = require 'cheerio'
request = require 'request-promise-native'
request = request.defaults
  jar: true

defaults = require './config.json'
settings = require './settings'
if not settings.username or not settings.password
  console.error 'You must provide both username and password'
  process.exit 1

get = (queryParams) ->
  return request.get "http://reign.ws/?#{querystring.stringify queryParams}"
post = (form) ->
  return request.post 'http://reign.ws/', { form }

login = (username, password) ->
  console.log "Logging in with #{username}:#{password}"
  return post
    login_username: username
    login_password: password
    cookie: 1
    gologin: 1

extractId = (body) ->
  return () ->
    $ = cheerio.load body
    uraniumTd = $('#universe > div.column_mid > div > div:nth-child(3) > div > table > tr > td:nth-child(2) > div > table > tr > td:nth-child(1) > table > tr:nth-child(4) > td:nth-child(3) > a')
    if uraniumTd.length is 0
      return -1
    href = uraniumTd.attr('href')
    return href.substr 9

# Set which nation we want to be working in
setNation = (nation) ->
  return () ->
    console.log "Setting nation to #{nation}"
    return get setnation: nation

# Collect uranium
collectUranium = () ->
  return (id) ->
    if id isnt -1
      console.log "Collection uranium: #{id}"
      get collect: id

# Harvest farms
harvestFarm = (farm) ->
  return () ->
    console.log "Harvesting farm: #{farm}"
    return get harvest: farm

# Crops
crops = [
  'cabbage'
  'rice'
  'cotton'
  'tomato'
  'peanuts'
  'peas'
  'wheat'
  'avocado'
  'strawberry'
  'coffee'
  'potato'
  'pepper'
  'pumpkin'
  'tobacco'
  'grapes'
  'corn'
  'blackberry'
  'sugar'
  'cannabis'
  'cocoa'
]

# Plant farm with crop
plantFarm = (farm, cropToPlant) ->
  crop = if typeof cropToPlant is 'number' then cropToPlant else crops.indexOf cropToPlant.toLowerCase()
  return () ->
    console.log "Planting farm: #{farm}\nWith crop: #{crop}"
    return post
      plant_structure: farm
      plant: crop

useInitiative = (initiative) ->
  options = {
    culture: 5
    land: 8
  }
  return () ->
    return unless initiative and initiative of options
    console.log "Using initiative"
    return get eo: options[initiative]

pe = (err) ->
  console.error err

doThings = (world) ->
  return (html) ->
    Promise.resolve()
    .then extractId html
    .then collectUranium()
    .then harvestFarm world.farm1.id
    .then plantFarm world.farm1.id, world.farm1.crop
    .then harvestFarm world.farm2.id
    .then plantFarm world.farm2.id, world.farm2.crop
    .then useInitiative world.initiative
    .catch pe

console.log ''
console.log ''
console.log Date()
login settings.username, settings.password
.then () ->
  console.log 'logged in'
  Promise.resolve()
  .then setNation settings.worlds[0].id
  .then doThings settings.worlds[0]
  .then setNation settings.worlds[1].id
  .then doThings settings.worlds[1]
.catch pe
