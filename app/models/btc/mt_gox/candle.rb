class Btc::MtGox::Candle
  include Mongoid::Document

  field :date, type: Time
  field :open, type: Float
  field :close, type: Float
  field :high, type: Float
  field :low, type: Float
  field :amount, type: Float

  index :date
end

Candle = Btc::MtGox::Candle
