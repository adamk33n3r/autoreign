---
---

console.log 'in coffee'
angular.module 'AutoReignApp', []

.config ($interpolateProvider) ->
  $interpolateProvider.startSymbol('<%').endSymbol('%>')

.controller 'MainController', () ->
  @form = {}
  @offense = {
    soldier: 0
    recluse: 0
    guardian: 0
    brute: 0
  }
  window.mc = this
