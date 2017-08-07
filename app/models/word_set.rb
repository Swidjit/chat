class WordSet < ActiveRecord::Base
  serialize :words, Array
end