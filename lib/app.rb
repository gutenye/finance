log = puts

module App
  class << self
    def mtgox_by_candle
      MtGoxByCandle.new.main
    end

    def mtgox_by_minute
      MtGoxByMinute.new.main
    end
  end

  # popluate Btc::MtGox::Trade data
  class MtGoxByCandle
    def gen_data(last_date, latest_date)
      map = <<-EOF
function(){
  var d = this.date;
  var date = new Date(d.getFullYear(), d.getMonth(), d.getDate());

  emit(date, { date: date, amount: this.amount, open: this.price, close: this.price, high: this.price, low: this.price });
}
      EOF

      reduce = <<-EOF
function(key, values){
  var result = { date: key, amount: 0, open: values[0].open, close: values[values.length-1].close, high: values[0].high, low: values[0].low};

  values.forEach(function(value){
    result.amount += value.amount;

    if (result.high < value.high)
      result.high = value.high;

    if (result.low > value.low)
      result.low = value.low;
  });

  return result;
}
      EOF

      rst = Btc::MtGox::Trade.collection.map_reduce(map, reduce, :out => "tmp", :query => {"date" => {"$gte" => last_date , "$lt" => latest_date}})
      #pd "result", rst.find.to_a

      db = Mongoid.master
      db["tmp"].find.each{ |doc| db["btc_mt_gox_trade_by_candles"].insert(doc["value"].tap{|v|v.delete("price")}) }
      db["tmp"].remove
    end

    # reduce time to a day.
    def reduce_time(t)
      Time.new(t.year, t.month, t.day)
    end

    def main
      return unless Btc::MtGox::Trade.exists?

      last_date = Btc::MtGox::TradeByCandle.exists? ? Btc::MtGox::TradeByCandle.last.date+1.day : reduce_time(Btc::MtGox::Trade.first.date)
      latest_date = reduce_time(Btc::MtGox::Trade.last.date)

      return if last_date >= latest_date

      gen_data(last_date, latest_date)
    end
  end

  # populate Btc::MtGox::TradeByMinute data
  class MtGoxByMinute
    def gen_data(last_date, latest_date)
map = <<EOF
function(){
  var d = this.date;
  var date = new Date(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours(), d.getMinutes());

  emit(date, { date: date, total_price: this.price, amount: this.amount, count: 1, price: 0});
}
EOF

reduce = <<EOF
function(key, values){
  var result = { date: key, total_price: 0, amount: 0, count: 0, price: 0};

  values.forEach(function(value){
    result.amount += value.amount;
    result.total_price += value.total_price;
    result.count += value.count;
  });

  return result;
}
EOF

finalize = <<EOF
function(key, value){
  if (value.count > 0)
    value.price = value.total_price / value.count;

  return value;
}
EOF

      rst = Btc::MtGox::Trade.collection.map_reduce(map, reduce, :out => "tmp2", :finalize => finalize, :query => {"date" => {"$gte" => last_date , "$lt" => latest_date}})
      #pd "result", rst.find.to_a

      db = Mongoid.master
      db["tmp2"].find.each{ |doc| db["btc_mt_gox_trade_by_minutes"].insert(doc["value"].tap{|v|v.delete("total_price"); v.delete("count")}) }
      db["tmp2"].remove
    end

    # reduce time to a day.
    def reduce_time(t)
      Time.new(t.year, t.month, t.day, t.hour, t.min)
    end

    def main
      return unless Btc::MtGox::Trade.exists?

      #last_date = Btc::MtGox::TradeByMinute.exists? ? Btc::MtGox::TradeByMinute.last.date+1.minute : reduce_time(Btc::MtGox::Trade.first.date)
      last_date = Btc::MtGox::TradeByMinute.exists? ? Btc::MtGox::TradeByMinute.last.date+1.minute : Time.new(2012,5,7)
      latest_date = reduce_time(Btc::MtGox::Trade.last.date)

      return if last_date >= latest_date

      gen_data(last_date, latest_date)
    end
  end
end
