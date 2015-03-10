/* 

$ mongo finance_development x.js

*/

map = function(){
  var d = this.date;
  var date = new Date(d.getFullYear(), d.getMonth(), d.getDate());

  emit(date, { date: date, amount: this.amount, open: this.price, close: this.price, high: this.price, low: this.price });
}

reduce = function(key, values){
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


var ret = db.btc_mt_gox_trades.mapReduce(map, reduce, "tmp");
printjson(ret);
