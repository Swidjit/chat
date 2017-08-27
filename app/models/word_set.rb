class WordSet < ActiveRecord::Base
  serialize :words, Array
  after_create :add_main_word

  def add_main_word
    words = self.words
    words << self.keyword
    self.update_attribute(:words,words)
  end
end
