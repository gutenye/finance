#= require_self
#= require      ./models
#= require      ./routes
#= require      ./controllers
#= require      ./initialize
#= require      ./views
#= require_tree ./templates
#
# require_tree ./models
# require_tree ./controllers
# require_tree ./routes
# require_tree ./helpers
# require_tree ./views

window.A = window.App = Ember.Application.create
  store: DS.Store.create
    revision: 4
    adapter: DS.RESTAdapter.create()

window.V = Ember.Namespace.create() # View
window.C = Ember.Namespace.create() # Controller
window.S = Ember.Namespace.create() # State
window.L = Ember.Namespace.create() # Layout
window.Rc = Ember.Object.create
  amount_filter: 10  # only display amount >=10
  chart:
    controller: null
    type: null
    start: null
    end: null

A.fetchTrades = ->
  $.get "/trades.json", {type: Rc.chart.type , start: Rc.chart.start(), end: Rc.chart.end()}, (data) ->
    data = data["trades"]
    data.forEach (d)->
      d.date = new Date(d.date)
    Rc.chart.controller.set "content", data

  A.fetchTrades

# ¤route
A.Router = Ember.Router.extend
  location: "hash"
  #enableLogging: true

  root: Ember.State.extend
    index: Ember.State.extend
      route: "/"
      connectOutlets: ()->
        L.root.set "content", V.Root.create()

    charts: Ember.State.extend
      route: "/charts"
      enter: ()->
        L.root.set "content", L.charts

      index: Ember.State.extend
        route: "/"
        redirectsTo: "realtime"

      realtime: Ember.State.extend
        route: "/realtime"
        connectOutlets: ()->
          L.charts.set "content", V.Charts.Realtime.create()
        enter: ()->
          Rc.chart.controller = C.realtime
          Rc.chart.type = "minute"
          Rc.chart.start = ()-> moment().subtract("days", 1).valueOf() / 1000
          Rc.chart.end = ()-> moment().valueOf() / 1000
          A.t = setInterval(A.fetchTrades(), 60*1000)
        exit: ()->
          clearInterval(A.t)

        oneDay: ()->
          Rc.chart.start = ()-> moment().subtract("days", 1).valueOf() / 1000
          A.fetchTrades()

        twoDay: ()->
          Rc.chart.start = ()-> moment().subtract("days", 2).valueOf() / 1000
          A.fetchTrades()

        threeDay: ()->
          Rc.chart.start = ()-> moment().subtract("days", 3).valueOf() / 1000
          A.fetchTrades()

      candle: Ember.State.extend
        route: "/candle"
        connectOutlets: ()->
          L.charts.set "content", V.Charts.Candle.create()
        enter: ()->
          Rc.chart.controller = C.candle
          Rc.chart.type = "candle"
          Rc.chart.start = ()-> moment().subtract("years", 1).valueOf() / 1000
          Rc.chart.end = ()-> moment().valueOf() / 1000
          A.t = setInterval(A.fetchTrades(), 24*3600*1000)
        exit: ()->
          clearInterval(A.t)

        oneMonth: ()->
          Rc.chart.start = ()-> moment().subtract("months", 1).valueOf() / 1000
          A.fetchTrades()
        twoMonth: ()->
          Rc.chart.start = ()-> moment().subtract("months", 2).valueOf() / 1000
          A.fetchTrades()
        threeMonth: ()->
          Rc.chart.start = ()-> moment().subtract("months", 3).valueOf() / 1000
          A.fetchTrades()
        oneYear: ()->
          Rc.chart.start = ()-> moment().subtract("years", 1).valueOf() / 1000
          A.fetchTrades()


# ¤controller
A.RealtimeController = Ember.ArrayController.extend
  content: []

A.CandleController = Ember.ArrayController.extend
  content: []

# ¤initialize
A.initialize()
router = A.router = A.get("stateManager")
C.realtime = router.get("realtimeController")
C.candle = router.get("candleController")

# ¤layout
L.root = Ember.View.create
  templateName: "ember/templates/layouts/root"
  classNames: ["root-layout"]

L.charts = Ember.View.create
  templateName: "ember/templates/layouts/charts"
  classNames: ["charts-layout"]

# ¤view
V.Root = Ember.View.extend
  templateName: "ember/templates/root"

V.ChartView = Ember.View.extend
  template: Ember.Handlebars.compile("")
  tagName: "svg"
  elementId: "chart"
  classNames: ["chart"]
  attributeBindings: ["_width:width", "_height:height"] 

  width: 1000
  height: 400
  padding: 20
  _width: (-> @get("width") + @get("padding")*20).property("width", "padding")
  _height: (-> @get("height") + @get("padding")*2).property("height", "padding")

  # create <svg>
  didInsertElement: ->
    [w, h, p] = [@get("width"), @get("height"), @get("padding")]
    elementId = @get("elementId")

    # ¤scales
    @x = d3.time.scale().range([0, w])
    @y = d3.scale.linear().range([h, 0])
    @z = d3.scale.linear().range([h, 0])

    # ¤axies
    @xAxis = d3.svg.axis().scale(@x).orient("bottom")
    @yAxis = d3.svg.axis().scale(@y).orient("right")
    @zAxis = d3.svg.axis().scale(@z).orient("left")

    @svg = d3.select("##{elementId}").append("g").attr("transform", "translate(#{p*2},#{p})")
    @svg.append("g").attr("class", "x axis").attr("transform", "translate(0,#{h})")
    @svg.append("g").attr("class", "y axis").attr("transform", "translate(#{w},0)")
    @svg.append("g").attr("class", "y grid").attr("transform", "translate(#{w},0)")
    @svg.append("g").attr("class", "z axis")

V.Charts = 
  Realtime: Ember.View.extend
    templateName: "ember/templates/charts/realtime"
    elementId: "realtime"
    controller: C.realtime

    chart: V.ChartView.extend
      didInsertElement: ()->
        @_super()
        [w, h, p] = [@get("width"), @get("height"), @get("padding")]

        @line = d3.svg.line()
          .x((d)=>@x(d.date))
          .y((d)=>@y(d.price))

        @linebar = d3.svg.linebar()
          .x((d)=>@x(d.date))
          .y0(@z(0))
          .y1((d)=>@z(d.amount))
          
        @svg.append("path")
          .attr("id", "path")
          .attr("class", "line")

        @svg.append("path")
          .attr("id", "bars")
          
      update: (->
        [w, h, p] = [@get("width"), @get("height"), @get("padding")]

        data = C.realtime.get("content")

        @x.domain([data[0].date, data[data.length-1].date])
        @y.domain([d3.min(data, (d)->d.price), d3.max(data, (d)->d.price)])
        @z.domain([0, d3.max(data, (d)->d.amount)])

        # x-axis, y-axis, y-grid, z-axis
        @svg.selectAll(".x.axis").call(@xAxis.ticks(d3.time.hours, 2).tickSize(0,0))
        @svg.selectAll(".y.axis").call(@yAxis.tickSize(0,0))
        @svg.selectAll(".y.grid").call(@yAxis.tickSize(-w,0))
        @svg.selectAll(".z.axis").call(@zAxis.tickSize(0,0))

        # z bars
        @svg.select("#bars")
          .attr("d", @linebar(data))

        # path
        @svg.select("#path")
          .attr("d", @line(data))
      ).observes("C.realtime.content")

  Candle: Ember.View.extend
    templateName: "ember/templates/charts/candle"
    elementId: "candle"
    controller: C.candle

    chart: V.ChartView.extend
      didInsertElement: ()->
        @_super()
        [w, h, p] = [@get("width"), @get("height"), @get("padding")]

        @candle = d3.svg.candle()
          .x((d)=>@x(d.date))
          .open((d)=>@y(d.open))
          .close((d)=>@y(d.close))
          .high((d)=>@y(d.high))
          .low((d)=>@y(d.low))

      update: (->
        [w, h, p] = [@get("width"), @get("height"), @get("padding")]

        data = C.candle.get("content")

        @x.domain([data[0].date, data[data.length-1].date])
        @y.domain([d3.min(data, (d)->d.low), d3.max(data, (d)->d.high)])
        @z.domain([0, d3.max(data, (d)->d.amount)])

        # x-axis, y-axis, y-grid, z-axis
        @svg.selectAll(".x.axis").call(@xAxis.ticks(d3.time.months, 1).tickSize(0,0))
        @svg.selectAll(".y.axis").call(@yAxis.tickSize(0,0))
        @svg.selectAll(".y.grid").call(@yAxis.tickSize(-w,0))
        @svg.selectAll(".z.axis").call(@zAxis.tickSize(0,0))

        @svg.select("#candleChart").remove()
        chart = @svg.append("svg")
          .attr("id", "candleChart")
          .attr("class", "candleChart")

        chart = chart.selectAll("path")
          .data(data)

        chart.enter().insert("path")
          .attr("d", @candle)
          .attr("class", (d) -> if (d.open-d.close)>0 then "down" else "up")

        chart.exit().remove()

      ).observes("C.candle.content")

# ¤end
L.root.append()
