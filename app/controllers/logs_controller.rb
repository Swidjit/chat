class LogsController < ApplicationController

  def create
    str = params[:input]
    puts Blacklist.is_blacklisted(str)
    puts !Phrase.check_if_valid(str)
    @log = Log.create(:input=>str,:mode=>params[:mode]) if (Blacklist.is_blacklisted(str) || !Phrase.check_if_valid(str))
  end

end
