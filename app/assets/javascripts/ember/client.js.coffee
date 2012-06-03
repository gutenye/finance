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

A.fetch_data = ->
  start = moment().subtract("days", 1).valueOf() / 1000
  end = moment().valueOf() / 1000

  $.get "/trades.json", {start: start, end: end}, (data) ->
    data = data["trades"]
    data.forEach (d)->
      d.date = new Date(d.date)

    C.realtime.set "content", data

  A.fetch_data

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
        pd "enter"
        L.root.set "content", L.charts

      index: Ember.State.extend
        route: "/"
        redirectsTo: "realtime"

      realtime: Ember.State.extend
        route: "/realtime"
        connectOutlets: ()->
          L.charts.set "content", V.Charts.Realtime.create()
        enter: ()->
          A.t = setInterval(A.fetch_data(), 60*1000)
        exit: ()->
          clearInterval(A.t)

      candle: Ember.State.extend
        route: "/candle"
        connectOutlets: ()->
          L.charts.set "content", V.Charts.Candle.create()


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
  #elementId: "realtime"  # IMPL
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

    # ¤line
    @line = d3.svg.line()
      .x( (d)-> @x(d.date) )
      .y( (d)-> @y(d.price) )

    @svg = d3.select("##{elementId}").append("g").attr("transform", "translate(#{p*2},#{p})")
    @svg.append("g").attr("class", "x axis").attr("transform", "translate(0, #{h})")
    @svg.append("g").attr("class", "y axis").attr("transform", "translate(#{w},0)")
    @svg.append("g").attr("class", "y grid").attr("transform", "translate(#{w}, 0)")
    @svg.append("g").attr("class", "z axis")
    @svg.append("g").attr("id", "bars")

V.Charts = 
  Realtime: V.ChartView.extend
    elementId: "realtime"

    # obverse("C.realtine.content")
    update: (->
      [w, h, p] = [@get("width"), @get("height"), @get("padding")]

      data = C.realtime.get("content")
      # 144 bars. one bar per 10 minutes
      slice_length = data.length._div(144)
      amount_data = [ ] # [ [date, amount], ..]
      data._eachSlice slice_length, (datas)->
        amount_data._push [datas._last().date, datas._sum((d)->d.amount)]

      @x.domain([data[0].date, data[data.length-1].date])
      @y.domain([d3.min(data, (d)->d.price), d3.max(data, (d)->d.price)])
      @z.domain([0, d3.max(data, (d)->d.amount)])

      # x axis
      #@svg.selectAll(".x.axis").call(@xAxis.ticks(d3.time.minutes, 4).tickSize(0,0))
      @svg.selectAll(".x.axis").call(@xAxis.ticks(d3.time.hours, 2).tickSize(0,0))

      # y axis
      @svg.selectAll(".y.axis").call(@yAxis.tickSize(0,0))

      # y grid
      @svg.selectAll(".y.grid").call(@yAxis.tickSize(-w,0))

      # z axis
      @svg.selectAll(".z.axis").call(@zAxis.tickSize(0,0))

      # z bars
      bar = @svg.select("#bars").selectAll(".bar").data(amount_data)
      bar.enter().append("line").attr("class", "bar").attr("x1", (d)=> @x(d[0])).attr("x2", (d)=> @x(d[0])).attr("y1", h).attr("y2", (d)=>@z(d[1]))
      bar.attr("x1", (d)=> @x(d[0])).attr("x2", (d)=>@x(d[0]))
      bar.exit().remove()

      # path
      path = @svg.selectAll(".line").data([1])
      path.enter().append("path").attr("class", "line")
      path.attr("d", @line(data))
    ).observes("C.realtime.content")

  Candle: V.ChartView.extend
    elementId: "candle"

    update: (->
      pd "update"
      [w, h, p] = [@get("width"), @get("height"), @get("padding")]

      data = C.realtime.get("content")
      candle_data = []
      for d in data
        candle_data.push [d.open, d.close, d.high, d.low]

      @candle.domain([0, 100])

      @svg = @svg.append("g")
        .selectAll("path")
          .data(candle_data)
        .enter().insert("path")
          .attr("d", @candle)
          .attr("class", (d) -> if (d[0]-d[1])>0 then "down" else "up")

    ).observes("C.candle.content")

# ¤end
L.root.append()
