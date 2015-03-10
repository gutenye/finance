/* 

$ mongo finance_development x.js

*/

map = function(){
  var d = this.date;
  var date = new Date(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours(), d.getMinutes());

  emit(date, { date: date, total_price: this.price, amount: this.amount, count: 1, price: 0});
}

reduce = function(key, values){
  var result = { date: key, total_price: 0, amount: 0, count: 0, price: 0};

  values.forEach(function(value){
    result.amount += value.amount;
    result.total_price += value.total_price;
    result.count += value.count;
  });

  return result;
}

finalize = function(key, value){
  if (value.count > 0)
    value.price = value.total_price / value.count;

  return value;
}

var ret = db.btc_mt_gox_trades.mapReduce(map, reduce, {out: "tmp2", finalize: finalize});
printjson(ret);
