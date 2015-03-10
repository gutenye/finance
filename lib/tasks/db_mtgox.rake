namespace :db do
  task :mtgox => :environment do
    App.mtgox_by_candle
    App.mtgox_by_minute
  end
end
