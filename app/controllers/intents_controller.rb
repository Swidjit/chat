class IntentsController < ApplicationController

  def interpret
    @response = Intent.ask(params[:input])
    respond_to do |format|
      format.json { render :json => {:success => @response[:success], :intent => @response[:response]} }
    end
  end
end