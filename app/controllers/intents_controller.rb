class IntentsController < ApplicationController

 def ask
   @response = Intent.ask(params[:query])

 end
end