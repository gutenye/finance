require "factory_girl_rails"
include Factory::Syntax::Methods

[ # trade
  [ "2012-1-1 12:10:01", 1.0, 10 ],
  [ "2012-1-1 12:10:02", 0.2, 10 ],
  [ "2012-1-1 12:10:03", 3.2, 10 ],
  [ "2012-1-1 12:10:04", 2.0, 10 ],
  [ "2012-1-2 12:10:01", 1.2, 10 ],
  [ "2012-1-2 12:11:01", 1.2, 10 ],
  [ "2012-1-3 12:10:01", 1.3, 11 ],
  [ "2012-1-4 12:10:01", 1.4, 12 ],
].each do |data|
  date, price, amount = data
  create :trade, date: date, price: price, amount: amount
end
