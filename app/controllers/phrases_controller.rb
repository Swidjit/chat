class PhrasesController < ApplicationController

  def autocomplete
    @phrases = Phrase.where('str LIKE ?',"#{params[:q]}%")
    respond_to do |format|
      format.json { render :json => @phrases.collect{|phrase| {:id => phrase.id, :str => phrase.str}} }
    end
  end

  def check_validity
    is_valid = Phrase.check_if_valid(params[:q])
    mode = 'partial'
    puts "valid:#{is_valid}"
    if is_valid
      puts 'hye'
      mode = Phrase.check_if_exact(params[:q])
    end
    respond_to do |format|
      format.json { render :json => {:success => is_valid, :mode => mode} }
    end
  end

end