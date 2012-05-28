module App
  class << self
    def gen_db_mtgox
      MtGox.new.main
    end
  end

  # popluate Btc::MtGox::Trade data
  class MtGox
    def gen_data(last_date, latest_date)
      map = <<-EOF
function(){
  var d = this.date;
  var date = new Date(d.getFullYear(), d.getMonth(), d.getDate());

  emit(date, { price: this.price, amount: this.amount,  
                date: date, open: this.price, close: this.price, high: this.price, low: this.price });
}

      EOF

      reduce = <<-EOF
function(key, values){
  var result = { price: -1, amount: 0,
                  date: key, open: null, close: null, high: 0, low: Number.MAX_VALUE };

  values.forEach(function(value){
    result.amount += value.amount;

    if (result.open == null)
      result.open = value.price;

    result.close = value.price;

    if (result.high < value.price)
      result.high = value.price;

    if (result.low > value.price)
      result.low = value.price;
  });

  return result;
}
      EOF

      rst = Btc::MtGox::Trade.collection.map_reduce(map, reduce, :out => "tmp", :query => {"date" => {"$gte" => last_date , "$lt" => latest_date}})
      # puts "result", rst.find.to_a

      db = Mongoid.master
      db["tmp"].find.each{ |doc| db["btc_mt_gox_candles"].insert(doc["value"].tap{|v|v.delete("price")}) }
    end

    # reduce time to a day.
    def time2day(t)
      Time.new(t.year, t.month, t.day)
    end

    def main
      return unless Btc::MtGox::Trade.exists?

      last_date = Btc::MtGox::Candle.exists? ? Btc::MtGox::Candle.last.date+1.day : time2day(Btc::MtGox::Trade.first.date)
      latest_date = time2day(Btc::MtGox::Trade.last.date)

      return if last_date >= latest_date

      gen_data(last_date, latest_date)
    end
  end
end
