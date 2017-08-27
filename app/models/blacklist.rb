class Blacklist < ActiveRecord::Base

  after_create :make_regexp

  def make_regexp
    #start the pattern.  along the way, we will convert it to a regexp
    regexp = self.pattern.dup.downcase

    # look for word option syntax in pattern eg 'how are you doing/feeling' -> 'how are you (doing/feeling)'
    words = regexp.split(" ")
    words.each do |word|
      if word.include? '/'
        regexp = regexp.gsub(word,"(#{word})")
      end
    end
    #now, lets use pipes instead of slashes for regexp syntax
    regexp = regexp.gsub('/',"|")

    chunks = regexp.split(' ')
    chunks.each do |ch|
      #look for set syntax ... and make sure there is no space in the match or else it could be two sets eg 'do you [like] [sports]'
      #may need to change if we want to allow sets names with more than one word
      #match a range of words ^(?:\w+\s){0,3}(?:\w+)$
      ch.scan(/(\[\w{0,60}\])/) do |match|
        set = WordSet.find_by_keyword(match[0][1..-2])
        str = '(' + set.words.join('|') + ')'
        regexp = regexp.gsub(match[0],str)
      end

    end

    #let's replace all underscore with spaces now that we have done our chunking
    regexp = regexp.gsub(/_/,' ')
    #allow for optional words, eg 'this ?strange thing -> 'this thing' or 'this strange thing' but not 'this odd thing'
    matches = regexp.scan(/\s\?\w+\s/)
    matches.each do |n|
      regexp = regexp.gsub(n,"(\\s#{n[2..-2]})? ")
    end
    #allow for wildcard endings eg 'scien*' -> 'science','scientist','scientific'
    regexp = regexp.gsub(/\*\s/,'(\w+)?\s')
    regexp = regexp.gsub(/\*/,'(\w+)?')
    #allow for infinite words betwen patterns, eg 'put ^ away ^' -> 'put away' or 'put that ridiculous thing away right now'
    regexp = regexp.gsub(/(\s)?\^(\s)?/,'\s.{0,}')
    #allow for finite number of words to appear between patterns, eg 'I {1} put' -> 'I put' or 'I last put', but not 'I most recently put'
    regexp = regexp.gsub(/\?\{\d\}\s/,"")
    matches = regexp.scan(/\{\d\}\s/)
    matches.each do |n|
      regexp = regexp.gsub(n,"(?:\\w+\\s){0,#{n[1]}}")
    end
    #add capturing group around entire expression
    regexp = '(' + regexp + ')'

    self.update_attribute(:regexp, regexp)
    puts regexp
  end

  def self.is_blacklisted(input)
    match = false
    input.split(' ').each do |word|
      records = Blacklist.find_by_sql("select * from blacklists where blacklists.regexp like '%"+word+"%'")
      records.each do |p|
        input.scan(/#{p.regexp}/) do |hit|
          puts 'het'
          match = true
          puts p.regexp
        end
      end
    end
    return match
  end

end
