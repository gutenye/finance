#!/usr/bin/env coffee
require "pdjs"
zmq = require("zmq")
mtgox = require("mtgox-socket-client")

IPC = "ipc:///tmp/guten.finance.ipc"

push = zmq.socket("push")
push.bindSync(IPC)

client = mtgox.connect()
client.on "open", ->
  pd "open"
  client.unsubscribe mtgox.getChannel("depth").key
  client.unsubscribe mtgox.getChannel("ticker").key

client.on "error", (err)->
  pd "error", err

client.on "close", ->
  pd "close"

client.on "trade", (data) ->
  data = data["trade"]

  # skip non-USD currency 
  return unless data["price_currency"] == "USD"   

  push.send JSON.stringify(data)
