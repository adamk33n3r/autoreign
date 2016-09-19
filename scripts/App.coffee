---
---

$.jqplot.config.enablePlugins = true

angular.module 'AutoReignApp', [
  'ui.chart'
]

.config ($interpolateProvider) ->
  $interpolateProvider.startSymbol('<%').endSymbol('%>')

.controller 'MainController', class
  UNITS: {
    soldiers: [1, 1]
    recluse: [2, 1]
    guardians: [1, 3]
    brutes: [3, 2]
    razors: [3, 1]
    radicals: [8, 0]
    mercs: [2, 1]

    sparrows: [3, 1]
    hives: [1, 3]
    spades: [1, 3]
    sickles: [3, 1]
    warthogs: [4, 1]
    mirages: [3, 2]
    conscripts: [0, 1]

    nukes: [1000, 0]
  }

  constructor: ($scope, @testData) ->
    landCounts = @getChart1Data false
    for land, data of @getChart1Data false
      result = regression 'linear', data
      console.log result
      #console.log data.reduce (prev, next) ->
      #  console.log prev, next
      #  [x1, y1] = prev
      #  [x2, y2] = next
      #  return (y2 - y1) / (x2 - x1)
      #, [0, 0]
    @chartOptions = {
      animate: true
      cursor:
        show: true
        showTooltip:true
      legend:
        show: true
      highlighter:
        tooltipFormatString: "%#.2f"
        formatString: "%#.2f"
      trendline:
        show: false
      axes:
        xaxis:
          label: 'Soldiers/Raw Defense'
          labelRenderer: $.jqplot.CanvasAxisLabelRenderer
          labelOptions:
            fontFamily: 'Roboto'
        yaxis:
          label: 'Defense Efficiency (DE)'
          labelRenderer: $.jqplot.CanvasAxisLabelRenderer
          labelOptions:
            fontFamily: 'Roboto'
      series: ({
        label: "#{land} Land #{regression('linear', data).string}"
        pointLabels:
          show: true
        rendererOptions:
          animation:
            speed: 5000
          highlightMouseOver: true
        trendline:
          lineWidth: 5
      } for land, data of landCounts)
      highlighter:
        show: true
        showLabel: true
    }
    @chart2Options = angular.copy @chartOptions
    @chart2Options.axes.xaxis.label = 'Total Defense'
    @form = {}
    @offense = {
      soldiers: 0
      recluse: 0
      guardians: 0
      brutes: 0
      razors: 0
      radicals: 0
      mercs: 0

      sparrows: 0
      hives: 0
      spades: 0
      sickles: 0
      warthogs: 0
      mirages: 0

      nukes: 0
    }

    @defense = {
      soldiers: 0
      recluse: 0
      guardians: 0
      brutes: 0
      razors: 0
      radicals: 0
      mercs: 0

      sparrows: 0
      hives: 0
      spades: 0
      sickles: 0
      warthogs: 0
      mirages: 0
      conscripts: 0

    }

    @morale = 0
    @de = 0

    # Could change to ngChange, right?
    $scope.$watch () =>
      @defenseReport
    , @_parseIntel

  getChart1Data: (values = true) ->
    chartData = {}
    for item in @testData
      if item.land not of chartData
        chartData[item.land] = []
      chartData[item.land].push [item.soldiers, item.de]
    chartDataList = (item for land, item of chartData)
    return if values then chartDataList else chartData

  getChart2Data: (values = true) ->
    chartData = {}
    for item in @testData
      if item.land not of chartData
        chartData[item.land] = []
      chartData[item.land].push [item.totalDefense, item.de]
    chartDataList = (item for land, item of chartData)
    return if values then chartDataList else chartData

  j1: () ->
    @_sumPower(@_filter @offense, ['soldiers', 'recluse', 'guardians', 'brutes']) / @totalOffense

  j2: () ->
    @_sumPower(@_filter @offense, ['radicals', 'guardians', 'brutes', 'warthogs']) / @totalOffense

  j3: () ->
    @_sumPower(@_filter @offense, ['brutes', 'radicals', 'sparrows', 'hives', 'warthogs']) / @totalOffense

  j4: () ->
    @_sumPower(@_filter @offense, ['radicals', 'recluse', 'brutes', 'sickles']) / @totalOffense

  j5: () ->
    @totalOffense = @_sumPower @offense
    return @totalOffense

  j6: () ->
    @totalDefense = @_sumPower @defense, false
    return @totalDefense

  j7: () ->
    @_sumPower(@_filter @offense, ['soldiers', 'mercs', 'radicals']) / @totalOffense

  j8: () ->
    @_sumPower(@_filter @offense, ['recluse', 'guardians']) / @totalOffense

  j9: () ->
    @_sumPower(@_filter @offense, ['brutes', 'razors']) / @totalOffense

  j10: () ->
    @_sumPower(@_filter @offense, ['sparrows', 'hives', 'spades', 'warthogs', 'mirages', 'sickles']) / @totalOffense

  # DEFENSE
  j11: () ->
    @_sumPower(@_filter(@defense, ['soldiers', 'recluse', 'guardians', 'brutes']), false) / @totalDefense

  j12: () ->
    @_sumPower(@_filter(@defense, ['guardians', 'brutes', 'warthogs']), false) / @totalDefense

  j13: () ->
    @_sumPower(@_filter(@defense, ['brutes', 'sparrows', 'hives', 'warthogs']), false) / @totalDefense

  j14: () ->
    @_sumPower(@_filter(@defense, ['spades', 'razors', 'mirages', 'sickles']), false) / @totalDefense

  j15: () ->
    @_sumPower(@_filter(@defense, ['soldiers', 'mercs', 'conscripts']), false) / @totalDefense

  j16: () ->
    @_sumPower(@_filter(@defense, ['recluse', 'guardians']), false) / @totalDefense

  j17: () ->
    @_sumPower(@_filter(@defense, ['brutes', 'razors']), false) / @totalDefense

  j18: () ->
    @_sumPower(@_filter(@defense, ['sparrows', 'hives', 'spades', 'warthogs', 'mirages', 'sickles']), false) / @totalDefense


  offenseScore: () ->
    return @totalOffense * (
      @j1() * @j15() +
      @j2() * @j16() +
      @j3() * @j17() +
      @j4() * @j18() + 1
    )# * (1 + @retribution / 2)

  defenseScore: () ->
    return @totalDefense * (
      @j11() * @j7() +
      @j12() * @j8() +
      @j13() * @j9() +
      @j14() * @j10() + 1
    ) * (1 + @morale / 200) * @de

  _filter: (units, unitNames) ->
    return unitNames
     .reduce (res, key) ->
       res[key] = units[key]
       return res
     , {}

  _sumPower: (units, attack = true) ->
    sum = 0
    for unit, count of units
      sum += @UNITS[unit][if attack then 0 else 1] * count
    return sum

  _parseIntel: (report) =>
    unless report? and report isnt ''
      @morale = 0
      @de = 0
      for unit, count of @defense
        @defense[unit] = 0
      return
    console.log report
    try
      @defense.soldiers   = @_getUnitCount report.match(/(\d+)\/Soldier/)
      @defense.mercs      = @_getUnitCount report.match(/(\d+)\/Mercenary/)
      @defense.conscripts = @_getUnitCount report.match(/(\d+)\/Conscripts/)
      @defense.recluse    = @_getUnitCount report.match(/(\d+)\/Recluse/)
      @defense.guardians  = @_getUnitCount report.match(/(\d+)\/Guardian/)
      @defense.brutes     = @_getUnitCount report.match(/(\d+)\/Brute/)
      @defense.sparrows   = @_getUnitCount report.match(/(\d+)\/Sparrow/)
      @defense.hives      = @_getUnitCount report.match(/(\d+)\/Hive/)
      @defense.spades     = @_getUnitCount report.match(/(\d+)\/Spade/)
      @defense.razors     = @_getUnitCount report.match(/(\d+)\/Razorback/)
      @defense.warthogs   = @_getUnitCount report.match(/(\d+)\/Warthog/)
      @defense.sickles    = @_getUnitCount report.match(/(\d+)\/Sickle/)
      console.log @defense
      @morale             = report.match(/: (\d+)% Morale/)[1]
      @de                 = report.match(/@ (\d(?:.\d\d?)?) DE/)[1]
    catch e
      console.error 'Malformed intel report', e

  _getUnitCount: (match) ->
    if match?.length > 1
      return parseInt match[1], 10
    else
     return 0

.filter 'capitalize', () ->
  return (str) ->
    return str.charAt(0).toUpperCase() + str.slice(1)
