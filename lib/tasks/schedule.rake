task :schedule => :environment do
  scheduler = Rufus::Scheduler.start_new

  scheduler.every "1d", :first_in => "1s" do
    App.mtgox_by_candle
  end

  scheduler.every "1m", :first_in => "1s" do
    App.mtgox_by_minute
  end

  scheduler.join
end
