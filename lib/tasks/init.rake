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
    files = ['phrases.csv','nouns.csv','core.csv']
    files.each do |f|
      file = File.open(f)
      file.each do |line|
        Phrase.create(:str=>line.downcase) if line.length > 0
      end
    end
    puts Phrase.all.count
  end

end