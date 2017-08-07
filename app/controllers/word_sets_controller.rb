class WordSetsController < ApplicationController

  def create

    @set=WordSet.create(:keyword=>params[:word_set][:keyword], :words=> params[:word_set][:words].gsub(', ',',').split(','))
  end

  def destroy
    @set=WordSet.find(params[:id])
    @set.destroy
  end

  def index
    @sets = WordSet.all
  end

  def update
    arr = params[:word_set][:words].gsub(', ',',').split(',')
    @word_set = WordSet.find(params[:id])
    respond_to do |format|
      if @word_set.update_attributes(:words=>arr)
        format.html { redirect_to(@word_set, :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@word_set) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@word_set) }
      end
    end
  end
end