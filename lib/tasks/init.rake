namespace :init do
  task :seed => :environment do
    WordSet.delete_all
    WordSet.create(:keyword=>'explain', :words=>['define','tell','teach','explain','discuss','speak','talk','paraphrase','learn','what is','describe','illustrate','about'])
    WordSet.create(:keyword=>'clarify', :words=>['again','example','better','clarify','say it another way','more clear','simplify','spell out', 'easy'])
    WordSet.create(:keyword=>'detail', :words=>['more','further','better','again','with examples','detail'])
    WordSet.create(:keyword=>'subject', :words=>['mass','relativity','gravity','light','energy','matter','space'])
    WordSet.create(:keyword=>'topic', :words=>['atom bomb', 'black holes', 'quantum mechanics', 'solar system', 'twin paradox','special relativity','sun','universe','wormhole'])
    WordSet.create(:keyword=>'like', :words=>['like','fond','enjoy','appreciate','dig','pleasure','fancy','fun','love','favorite','best'])
    WordSet.create(:keyword=>'feel', :words=>['feel','opinion','attitude','view','think','stance','perspective','thought'])
    WordSet.create(:keyword=>'children', :words=>['children','kids','offspring','progeny','child','son','daughter'])
    WordSet.create(:keyword=>'us', :words=>['us','united states','usa','america'])
    WordSet.create(:keyword=>'advise', :words=>['advice','advise','suggest','recommend','tip','guidance','directions','counsel'])

    #seed intent
    a = Intent.create(:name=>'test',:response=>'yes',:pattern=>'this ^ test', :grouping_id => 1)
    a.patterns << Pattern.new(:pattern=>'how old ^ you')

  end

  task :import => :environment do
    Phrase.delete_all
    files = ['phrases.csv','nouns.csv','core.csv','adjectives.csv']
    files.each do |f|
      file = File.open(f)
      file.each do |line|
        Phrase.create(:str=>line.downcase.gsub(/[^0-9a-z ]/i, '')) if line.length > 0
      end
    end

    #import intents and patterns
    Intent.delete_all
    Pattern.delete_all
    files = ['intents.csv']
    files.each do |f|
      file = File.open(f)
      file.each do |line|
        if line.length > 0
          parts = line.split(',')
          puts parts[0].length, parts[3].length
          if i = Intent.create(:name => parts[0], :response => parts[0], :pattern => parts[1])
            i.patterns << Pattern.create(:pattern=>parts[2]) if parts[2].length > 2
            i.patterns << Pattern.create(:pattern=>parts[3]) if parts[3].length > 2
          end
        end

      end
    end
  end

  task :break_patterns => :environment do
    Pattern.all.each do |p|
      s = p.regexp
      b = []
      s.split(/(})/).each_slice(2) { |s| b << s.join }
      p.r1 = b[0] if b[0]
      p.r2 = b[1] if b[1]
      p.r3 = b[2] if b[2]
      p.r4 = b[3] if b[3]
      p.save
    end
  end

end