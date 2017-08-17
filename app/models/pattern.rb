class Pattern < ActiveRecord::Base
  belongs_to :intent

  scope :by_intent_desc, -> { joins(:intent).order('intents.intent_num DESC') }
  scope :by_intent_asc, -> { joins(:intent).order('intents.intent_num ASC') }

  after_create :make_regexp
  #after_update :make_regexp, if: :pattern_changed?

  def make_regexp
    @intent = self.intent
    regexp = self.pattern.dup.downcase
    words = regexp.split(" ")
    words.each do |word|
      if word.include? '/'
        regexp = regexp.gsub(word,"(#{word})")

      end

    end
    regexp = regexp.gsub('/',"|")
    regexp = regexp.gsub('^ ','.{0,60}').gsub(' ^','.{0,60}').gsub(' *','.{1,60}').gsub('* ','.{1,60}').gsub('^','.{1,60}').gsub(' [','.{0,60}[')
    regexp = regexp.gsub(' .{0,60}','.{0,60}')
    regexp = regexp.gsub(' .{1,60}','.{1,60}')
    regexp = '.{0,60}' + regexp + '.{0,60}'
    self.regexp = regexp
    puts "r:#{self.regexp}"
    chunks = self.pattern.split(' ')
    chunks.each do |ch|
      puts "ch: #{ch}"
      result= Regexp.new(/\[.{0,12}\]/) =~ ch
      if(result==0)
        set = WordSet.find_by_keyword(ch[1..-2])
        str = '(' + set.words.join('|') + ')'
        regexp = self.regexp.gsub(ch,str)
        self.regexp = regexp
      end
    end
    self.save
  end

  def respond(input)
    resp = self.intent.response
    puts resp
    parts = self.pattern.split(' ')
    parts.each do |p|
      match = Regexp.new(/^\[((?!\s).)*\]$/) =~ p
      if match
        set = WordSet.find_by_keyword(p[1..-2])
        word = ''
        set.words.each do |w|
          word = w if input.scan(/\s#{w}\s/).present?
        end
        puts word
        resp = resp.sub('*',word)
      end
      puts resp
    end
    return resp
  end

  def respond2(input)
    resp = self.intent.response
    puts resp
    parts = self.pattern.split(' ')
    parts.each do |p|
      match = Regexp.new(/^\[((?!\s).)*\]$/) =~ p
      if match
        set = WordSet.find_by_keyword(p[1..-2])
        word = ''
        matched = false
        set.words.each do |w|
          word = w if input.scan(/\s#{w}\s/).present?
          matched = true
        end
        puts word
        if matched
          resp = resp.sub('*',word)
        else
          resp = resp.sub('*',p)
        end
      end
      puts resp
    end
    return resp
  end
end
