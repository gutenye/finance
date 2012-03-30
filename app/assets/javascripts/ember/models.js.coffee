A.Btc = Ember.Namespace.create()
A.Btc.MtGox = Ember.Namespace.create()

A.Trade = DS.Model.extend
  tid: DS.attr("number")
  date: DS.attr("date")
  price: DS.attr("number")
  amount: DS.attr("number")
  trade_type: DS.attr("string")
