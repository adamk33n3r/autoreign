querystring = require 'querystring'
cheerio = require 'cheerio'
request = require 'request-promise-native'
request = request.defaults
  jar: true

settings = require './settings.json'

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

extractIds = (body) ->
  $ = cheerio.load body
  uraniumTd = $('#universe > div.column_mid > div > div:nth-child(3) > div > table > tr > td:nth-child(2) > div > table > tr > td:nth-child(1) > table > tr:nth-child(4) > td:nth-child(3)')
  console.log uraniumTd.html()

# Set which nation we want to be working in
setNation = (nation) ->
  return () ->
    console.log "Setting nation to #{nation}"
    return get setnation: nation

# Collect uranium
collectUranium = (id) ->
  return () ->
    console.log "Collection uranium: #{id}"
    get collect: id

# Harvest farms
harvestFarm = (farm) ->
  return () ->
    console.log "Harvesting farm: #{farm}"
    return get harvest: farm

# Plant farm with crop
plantFarm = (farm, crop) ->
  return () ->
    console.log "Planting farm: #{farm}\nWith crop: #{crop}"
    # Crops:
    # 	1: Cabbage
    # 	2: Rice
    # 	3: Cotton
    # 	4: Tomato
    # 	5: Peanuts
    # 	6: Peas
    # 	7: Wheat
    # 	8: Avocado
    # 	9: Strawberry
    # 	10: Coffee
    # 	11: Potato
    # 	12: Pepper
    # 	13: Pumpkin
    # 	14: Tobacco
    # 	15: Grapes
    # 	16: Corn
    # 	17: Blackberry
    # 	18: Sugar
    # 	19: Cannabis
    # 	20: Cocoa
    return post
      plant_structure: farm
      plant: crop

getCulture = () ->
  return () ->
    console.log "Using initiative"
    return get eo: 5
    # Get culture twice
    return Promise.all [
      get eo: 5
      get eo: 5
    ]

pe = (err) ->
  console.error err

doThings = (world) ->
  return (html) ->
    Promise.resolve()
    .then extractIds html
    .then harvestFarm world.farm1.id
    .then plantFarm world.farm1.id, world.farm1.crop
    .then harvestFarm world.farm2.id
    .then plantFarm world.farm2.id, world.farm2.crop
    .then collectUranium world.uraniumId
    .then getCulture()
    .catch pe

login settings.username, settings.password
.then () ->
  console.log 'logged in'
  Promise.resolve()
  .then setNation settings.worlds[0].id
  .then doThings settings.worlds[0]
  .then setNation settings.worlds[1].id
  .then doThings settings.worlds[1]
.catch pe
