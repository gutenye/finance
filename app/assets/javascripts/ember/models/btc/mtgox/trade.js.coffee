A.Btc.MtGox.Trade = DS.Model.extend
  tid: DS.attr("number")
  date: DS.attr("date")
  price: DS.attr("number")
  amount: DS.attr("number")
  trade_type: DS.attr("string")
