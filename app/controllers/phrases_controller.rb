class PhrasesController < ApplicationController

  def autocomplete
    @phrases = Phrase.where('str LIKE ?',"%#{params[:q]}%")
    respond_to do |format|
      format.json { render :json => @phrases.collect{|phrase| {:id => phrase.id, :str => phrase.str}} }
    end
  end

end