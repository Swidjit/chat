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


    #remove spaces around wilcards so 'come here ^ now' -> 'come here^now'  ... could be more efficient with regexp gsub
    regexp = regexp.gsub('^ ','.{0,60}').gsub(' ^','.{0,60}').gsub(' *','.{1,60}').gsub('* ','.{1,60}').gsub('^','.{1,60}').gsub(' [','.{0,60}[')
    regexp = regexp.gsub(' .{0,60}','.{0,60}')
    regexp = regexp.gsub(' .{1,60}','.{1,60}')

    self.regexp = regexp

    #find any sets and adjust the regex accordingly
    chunks = self.pattern.split(' ')
    chunks.each do |ch|
      #look for set syntax ... and make sure there is no space in the match or else it could be two sets eg 'do you [like] [sports]'
      #may need to change if we want to allow sets names with more than one word
      result= Regexp.new(/\[((?!\s).)*\]/) =~ ch
      if(result==0)
        set = WordSet.find_by_keyword(ch[1..-2])
        str = '(' + set.words.join('|') + ')'
        regexp = self.regexp.gsub(ch,str)
        self.regexp = regexp
      end
    end

    self.save
  end

  def self.is_blacklisted(input)
    match = false
    input.split(' ').each do |word|
      records = Blacklist.find_by_sql("select * from blacklists where blacklists.regexp like '%"+word+"%'")
      records.each do |p|
        puts input.scan(/#{p.regexp}/).count
        match = true if input.scan(/#{p.regexp}/).count > 0
      end
    end
    puts match
    return match
  end

end
