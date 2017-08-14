class IntentsController < ApplicationController

  def interpret
    @response = Intent.ask(params[:input])
    respond_to do |format|
      format.json { render :json => {:success => @response[:success], :intent => @response[:response]} }
    end
  end

  def recommend
    input = params[:input]
    choices = ''
    params[:input].split(' ').each do |word|
      records = Pattern.find_by_sql("select * from patterns where patterns.regexp like '%"+word+"%'")
      records.each do |p|
        result= Regexp.new(p.regexp) =~ input
        if(result==0)
          response = p.respond(input)
          choices = choices + response + ',' unless choices.include? response
        end
      end
      records = Pattern.find_by_sql("select * from patterns where patterns.r1 like '%"+word+"%'")
      records.each do |p|
        result= Regexp.new(p.r1) =~ input
        if(result==0)
          response = p.respond(input)
          choices = choices + response + ',' unless choices.include? response
        end
      end
      records = Pattern.find_by_sql("select * from patterns where patterns.r2 like '%"+word+"%'")
      records.each do |p|
        result= Regexp.new(p.r2) =~ input
        if(result==0)
          response = p.respond(input)
          choices = choices + response + ',' unless choices.include? response
        end
      end
      records = Pattern.find_by_sql("select * from patterns where patterns.r3 like '%"+word +"%'")
      records.each do |p|
        result= Regexp.new(p.r3) =~ input
        if(result==0)
          choices = choices + p.intent.response + ',' unless choices.include? p.intent.response
        end
      end
    end
    choices = choices[0..-1]
    respond_to do |format|
      format.json { render :json => {:options => choices} }
    end

  end
end