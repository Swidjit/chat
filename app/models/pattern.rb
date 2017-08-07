class Pattern < ActiveRecord::Base
  belongs_to :intent

  scope :by_intent_desc, -> { joins(:intent).order('intents.intent_num DESC') }
  scope :by_intent_asc, -> { joins(:intent).order('intents.intent_num ASC') }

  after_create :make_regexp
  #after_update :make_regexp, if: :pattern_changed?

  def make_regexp
    @intent = self.intent
    regexp = self.pattern.dup
    words = regexp.split(" ")
    words.each do |word|
      if word.include? '/'
        regexp = regexp.gsub(word,"(#{word})")

      end

    end
    regexp = regexp.gsub('/',"|")
    regexp = regexp.gsub('^ ','.{0,60}').gsub(' ^','.{0,60}').gsub(' *','.{1,60}').gsub('* ','.{1,60}').gsub('^','.{1,60}')
    regexp = regexp.gsub(' .{0,60}','.{0,60}')
    regexp = regexp.gsub(' .{1,60}','.{1,60}')
    self.regexp = regexp
    @matches = self.pattern.scan(/\[.{0,12}\]/)
    @matches.each do |match|
      set = WordSet.find_by_keyword(match[1..-2])
      str = '(' + set.words.join('|') + ')'
      regexp = self.regexp.gsub(match,str)
      self.regexp = regexp
    end
    self.save
  end
end
