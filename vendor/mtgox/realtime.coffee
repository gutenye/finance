#!/usr/bin/env coffee
require "pdjs"
zmq = require("zmq")
mtgox = require("mtgox-socket-client")

IPC = "ipc:///tmp/guten.finance.ipc"

push = zmq.socket("push")
push.bindSync(IPC)

client = mtgox.connect()
client.on "open", ->
  client.unsubscribe mtgox.getChannel("depth").key
  client.unsubscribe mtgox.getChannel("ticker").key

client.on "trade", (msg) ->
  #pd "trade", msg
  push.send JSON.stringify(msg)
