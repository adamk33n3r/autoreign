querystring = require 'querystring'
request = require 'request-promise-native'
request = request.defaults
  jar: true

settings = require './settings.json'

get = (queryParams) ->
  return request.get "http://reign.ws/?#{querystring.stringify queryParams}"
post = (form) ->
  return request.post 'http://reign.ws', { form }

login = (username, password) ->
  return post
    login_username: username
    login_password: password
    cookie: 1
    gologin: 1

# Set which nation we want to be working in
setNation = (nation) ->
  return () ->
    return get setnation: nation

# Collect uranium
collectUranium = (id) ->
  return () ->
    get collect: id

# Harvest farms
harvestFarm = (farm) ->
  return () ->
    return get harvest: farm

# Plant farm with crop
plantFarm = (farm, crop) ->
  return () ->
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
    # Get culture twice
    return Promise.all [
      get eo: 5
      get eo: 5
    ]

pe = (err) ->
  console.error err

login settings.username, settings.password
.then () ->
  console.log 'logged in'
  console.log settings.worlds
  for world in settings.worlds
    console.log 'world:', world.id
    setNation(world.id)()
    .then collectUranium world.uraniumId
    .then harvestFarm world.farm1.id
    .then plantFarm world.farm1.id, world.farm1.crop
    .then harvestFarm world.farm2.id
    .then plantFarm world.farm2.id, world.farm2.crop
    .then getCulture()
    .catch pe
