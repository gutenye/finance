require "ffi-rzmq"
require "json"

module App
  class Realtime
    IPC = "ipc:///tmp/guten.finance.ipc"

    def self.start
      new.start
    end

    def initialize
      @ctx = ZMQ::Context.new
      @pull = @ctx.socket(ZMQ::PULL)
      @pull.connect IPC
      @cache = []
    end

    def start
      msg = ""
      loop do
        @pull.recv_string(msg)
        data = JSON.parse(msg)
        #puts "REALTIME recv_string #{data["trade"]["tid"]}"

        t = MtGox::Trade.new(data["trade"])
        @cache << t

        if $fetch_history_done
          @cache.each{|v| 
            puts "REALTIME Trade.find_or_create #{v.tid}"
            Btc::MtGox::Trade.find_or_create_by(v.to_hash(:tid, :date, :price, :amount, :trade_type))
          }
          @cache.clear
        end
      end
    end
  end
end
