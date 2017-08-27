class PhrasesController < ApplicationController

  def autocomplete
    @phrases = Phrase.where('str LIKE ?',"#{params[:q]}%")
    respond_to do |format|
      format.json { render :json => @phrases.collect{|phrase| {:id => phrase.id, :str => phrase.str}} }
    end
  end

  def check_validity
    #replace contractions
    subs = {"let's"=>"let us", "that's"=>"that is","ain't"=>"am not", "aren't"=>"are not", "can't"=>"cannot", "could've"=>"could have", "couldn't"=>"could not", "didn't"=>"did not", "doesn't"=>"does not", "don't"=>"do not", "gonna"=>"going to", "gotta"=>"got to", "hadn't"=>"had not", "hasn't"=>"has not", "haven't"=>"have not", "he'd"=>"he had", "he'll"=>"he will", "he's"=>"he is", "how'd"=>"how did", "how'll"=>"how will", "how's"=>"how has", "I'd"=>"I had", "I'll"=>"I shall", "I'm"=>"I am", "i've"=>"i have", "isn't"=>"is not", "it'd"=>"it would", "it'll"=>"it shall", "it's"=>"it is", "mayn't"=>"may not", "may've"=>"may have", "mightn't"=>"might not", "might've"=>"might have", "mustn't"=>"must not", "must've"=>"must have", "needn't"=>"need not", "o'clock"=>"of the clock", "ol'"=>"old", "oughtn't"=>"ought not", "shan't"=>"shall not", "she'd"=>"she had", "she'll"=>"she shall", "she's"=>"she has", "should've"=>"should have", "shouldn't"=>"should not", "should of"=>"should have", "somebody's"=>"somebody has", "someone's"=>"someone has", "something's"=>"something has", "that'll"=>"that will", "that're"=>"that are", "that'd"=>"that would", "there'd"=>"there had", "there're"=>"there are", "there's"=>"there is", "these're"=>"these are", "they'd"=>"they had", "they'll"=>"they shall", "they're"=>"they are", "they've"=>"they have", "this's"=>"this has", "those're"=>"those are", "tis"=>"it is", "twas"=>"it was", "wasn't"=>"was not", "we'd"=>"we had", "we'd've"=>"we would have", "we'll"=>"we will", "we're"=>"we are", "we've"=>"we have", "weren't"=>"were not", "what'd"=>"what did", "what'll"=>"what shall", "what're"=>"what are", "what's"=>"what has", "what've"=>"what have", "when's"=>"when has", "where'd"=>"where did", "where're"=>"where are", "where's"=>"where has", "where've"=>"where have", "which's"=>"which has", "who'd"=>"who would", "who'd've"=>"who would have", "who'll"=>"who shall", "who're"=>"who are", "who's"=>"who has", "who've"=>"who have", "why'd"=>"why did", "why're"=>"why are", "why's"=>"why has", "willn't / won't"=>"will not", "would've"=>"would have", "wouldn't"=>"would not", "y'all"=>"you all", "you'd"=>"you had", "you'll"=>"you shall", "you're"=>"you are", "you've"=>"you have"}
    str = ''
    input = params[:q].gsub(/[!?,;.]/, '')
    input.split(' ').each do |word|
      if subs[word].present?
        str = str + ' ' + subs[word]
      else
        str = str + ' ' + word
      end
    end
    changes = []
    #substritute for banned but necessary words
    Substitution.all.each do |s|
      if str.scan(/#{s.word}/).present?
        str = str.gsub(/#{s.word}/,s.synonyms[0])
        changes.push({:word => s.word, :synonyms=>s.synonyms[0]})
      end
    end
    puts str
    puts changes
    str = str.strip
    if !Blacklist.is_blacklisted(str)
      is_valid = Phrase.check_if_valid(str)
      mode = 'partial'
      if is_valid
        if params[:mode] == 'send'
          Log.create(:input=>params[:q],:mode=>'sent')
        end
        mode = Phrase.check_if_exact(str)
      end
      respond_to do |format|
        format.json { render :json => {:success => is_valid, :mode => mode, :changes=>changes} }
      end
    else
      respond_to do |format|
        format.json { render :json => {:success => :false, :mode => mode} }
      end
    end

  end

end
