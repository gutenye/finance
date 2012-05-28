FactoryGirl.define do
  sequence(:tid)

  factory :trade, :class => Btc::MtGox::Trade do
    tid
    date { Time.now }
    price 4.8
    amount 100
    trade_type "bid"
  end
end

