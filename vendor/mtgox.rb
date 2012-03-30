require File.expand_path("../../config/application", __FILE__)
require "#{Rails.root}/config/environment"

require "mtgox/fetch_history"
require "mtgox/realtime"

$fetch_history_done = false

# ruby realtime client
Thread.start { 
  puts "> start realtime client"
  App::Realtime.start 
}

# node realtime server
Thread.start { 
  puts "> start realtime server"
  system("coffee #{File.expand_path("../mtgox/realtime.coffee", __FILE__)}")
}

# fetch history
Thread.start { 
  puts "> start fetch history"
  App::FetchHistory.start 
}

Thread.list.each {|t| t.join}
