module App
  class FetchHistory
    def self.start
      new.start
    end

    def start
      last_tid = Btc::MtGox::Trade.exists? ? Btc::MtGox::Trade.last.tid : 0
      #last_tid = 1333031828998528

      loop do
        trades = MtGox.trades :since => last_tid
        break if trades.empty?

        trades.each {|t|
          puts "HISTORY Trade.create #{t.tid} #{t.date}"
          Btc::MtGox::Trade.create! t.to_hash(:tid, :date, :price, :amount, :trade_type)
        }
        last_tid = trades.last.tid

        #sleep 2
      end
      puts "HISTORY done"

      $fetch_history_done = true
    end
  end
end
