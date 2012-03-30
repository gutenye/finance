class Btc::MtGox::Trade
  include Mongoid::Document

  field :tid, type: Integer
  field :date, type: Time
  field :price, type: Float
  field :amount, type: Float
  field :trade_type, type: String

  index :tid
  index :date
end

Trade = Btc::MtGox::Trade
