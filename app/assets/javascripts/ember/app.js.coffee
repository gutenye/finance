#= require_self
#= require      ./models
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./templates

window.A = window.App = Ember.Application.create
  store: DS.Store.create
    revision: 3
    adapter: DS.RESTAdapter.create()

window.V = Ember.Namespace.create() # View
window.C = Ember.Namespace.create() # Controller
window.S = Ember.Namespace.create() # State
window.Rc = Ember.Object.create
  amount_filter: 10  # only display amount >=10

# mtgox realtime graph
C.realtime = Ember.ArrayController.create
  content: []

C.products = Ember.ArrayController.create
  content: []  # collection
  resource: null
  params: null
  attrs: ["Name", "Description"]

  index: ->
    S.pages.goToState "products.index"

  edit: ->
    params = @get("params")
    @set "resource", params["id"]
    S.pages.goToState "products.edit"

  show: ->
    params = @get("params")
    @set "resource", A.store.find(M.Product, params["id"])
    S.pages.goToState "products.show"


  values: ->
    resource = @get("resource")

    resource.get("optionTypes").map (item, idx, self)->
      values = item.get("values")
      ret = []

# ¤view
V.Home = Ember.View.extend
  templateName: "ember/templates/home"

  realtime: Ember.View.extend
    tagName: "svg"
    elementId: "realtime"
    attributeBindings: ["_width:width", "_height:height"] 
    template: Ember.Handlebars.compile("")
    dataBinding: "C.realtime.content"

    width: 1000
    height: 400
    padding: 20
    _width: (-> @get("width") + @get("padding")*20).property("width", "padding")
    _height: (-> @get("height") + @get("padding")*2).property("height", "padding")

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

    didInsertElement: ->
      [w, h, p] = [@get("width"), @get("height"), @get("padding")]

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

      @svg = d3.select("#realtime").append("g").attr("transform", "translate(#{p*2},#{p})")
      @svg.append("g").attr("class", "x axis").attr("transform", "translate(0, #{h})")
      @svg.append("g").attr("class", "y axis").attr("transform", "translate(#{w},0)")
      @svg.append("g").attr("class", "y grid").attr("transform", "translate(#{w}, 0)")
      @svg.append("g").attr("class", "z axis")
      @svg.append("g").attr("id", "bars")

      get_data = ->
        start = moment().subtract("days", 1).valueOf() / 1000
        end = moment().valueOf() / 1000

        $.get "/trades.json", {start: start, end: end}, (data) ->
          data = data["trades"]
          data.forEach (d)->
            d.date = new Date(d.date)

          C.realtime.set "content", data

        get_data
      @t = setInterval(get_data(), 60*1000)

    willDestroyElement: ->
      clearInterval(@t)

V.Empty = Ember.View.extend
  tempalteName: "ember/templates/empty"

# ¤states
S.pages = Ember.StateManager.create
  enableLogging: true

  home: Ember.ViewState.extend(view: V.Home)
  empty: Ember.ViewState.extend(view: V.Empty)
  #products: Ember.StateManager.create
    #index: Ember.ViewState.extend(view: V.Products.Index)

# ¤routes
Ember.routes.add "", (params)->
  S.pages.goToState "home"

Ember.routes.add "empty", (params)->
  S.pages.goToState "empty"


#realtime_view = S.pages.get("currentView").get("childViews").findProperty("elementId", "realtime")

