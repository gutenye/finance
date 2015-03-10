class Btc::MtGox::TradeByCandle
  include Mongoid::Document

  field :date, type: Time
  field :amount, type: Float
  field :open, type: Float
  field :close, type: Float
  field :high, type: Float
  field :low, type: String

  index :date
end

TradeByCandle = Btc::MtGox::TradeByCandle
