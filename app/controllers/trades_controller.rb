class TradesController < ApplicationController
  respond_to :json

  def index
    query = {:date => params[:start].to_f..params[:end].to_f}

    @trades = Btc::MtGox::Trade.where(query)
    #@trades = Btc::MtGox::Trade.limit(10)
    respond_with trades: @trades 
  end
end
