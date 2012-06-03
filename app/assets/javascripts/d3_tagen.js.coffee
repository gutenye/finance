# a candlestick path data generator.
#
# data: [ open, close, high, low ]
#
d3.svg.candlestick = ->
  chart = (d, i)->
    y = d3.scale.linear()
      .domain(domain)
      .range([ height, 0 ])

    ret = ""
    [open, close, high, low] = d
    [open, close] = [close, open] if (open-close)>0

    # candle
    [ w, p ] = [ 5, 2 ] # [20, 5]
    x0 = (w+p)*(i+1)

    # box
    x2 = (x0 - w/2)
    y2 = y(open)
    xx2 = x2 + w
    yy2 = y(close)
    ret += "M#{x2},#{y2}H#{xx2}V#{yy2}H#{x2}Z"

    # center line
    x2 = x0
    y2 = y(low)
    yy2 = y(open)
    ret += "M#{x2},#{y2}V#{yy2}"

    x2 = x0
    y2 = y(close)
    yy2 = y(high)
    ret += "M#{x2},#{y2}V#{yy2}"

    ret

  # end function chart

  width = 1
  height = 1
  domain = null

  chart.width = (x) ->
    return width unless arguments.length
    width = x
    chart

  chart.height = (x) ->
    return height unless arguments.length
    height = x
    chart

  chart.domain = (x) ->
    return domain unless arguments.length
    domain = x
    chart

  chart
