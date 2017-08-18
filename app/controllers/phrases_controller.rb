class PhrasesController < ApplicationController

  def autocomplete
    @phrases = Phrase.where('str LIKE ?',"#{params[:q]}%")
    respond_to do |format|
      format.json { render :json => @phrases.collect{|phrase| {:id => phrase.id, :str => phrase.str}} }
    end
  end

  def check_validity
    if !Blacklist.is_blacklisted(params[:q])
      is_valid = Phrase.check_if_valid(params[:q])
      mode = 'partial'
      if is_valid
        mode = Phrase.check_if_exact(params[:q])
      end
      respond_to do |format|
        format.json { render :json => {:success => is_valid, :mode => mode} }
      end
    else
       respond_to do |format|
        format.json { render :json => {:success => :false, :mode => mode} }
      end
    end

  end

end