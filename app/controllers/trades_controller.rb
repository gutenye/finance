class TradesController < ApplicationController
  TYPES = {
    default: Btc::MtGox::Trade,
    minute: Btc::MtGox::TradeByMinute,
    candle: Btc::MtGox::TradeByCandle
  }

  respond_to :json

  # type: "minute"
  # start, end
  def index
    query = {:date => params[:start].to_f..params[:end].to_f}
    klass = TYPES[(params[:type] || :default).to_sym]
    pd :klass, klass

    @trades = klass.where(query)
    #@trades = Btc::MtGox::Trade.limit(10)
    data = {trades: @trades}
    respond_with data
  end
end
