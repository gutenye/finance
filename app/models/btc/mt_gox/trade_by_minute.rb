class Btc::MtGox::TradeByMinute
  include Mongoid::Document

  field :date, type: Time
  field :price, type: Float
  field :amount, type: Float

  index :date
end

TradeByMinute = Btc::MtGox::TradeByMinute
