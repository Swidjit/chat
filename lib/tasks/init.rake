namespace :init do
  task :seed => :environment do
    WordSet.delete_all
    WordSet.create(:keyword=>'are', :words=>['are','is','am'])
    WordSet.create(:keyword=>'was', :words=>['was','were'])
    WordSet.create(:keyword=>'do', :words=>['do','does'])
    WordSet.create(:keyword=>'go', :words=>['go','goes'])
    WordSet.create(:keyword=>'you', :words=>['you','he','she','they','we','I'])


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
      p.r2 = b[0]+b[1] if b[1]
      p.r3 = b[0]+b[1]+b[2] if b[2]
      p.r4 = b[0]+b[1]+b[2]+b[3] if b[3]
      p.save
    end
  end

  task :find_wildcards => :environment do
    input = 'where is that he now going'
    pattern = Pattern.find(171)
    pttrn = pattern.pattern
    response = pattern.intent.response
    parts = pttrn.split(' ')
    parts.each do |p|
      match = Regexp.new(/^\[((?!\s).)*\]$/) =~ p
      if match
        set = WordSet.find_by_keyword(p[1..-2])
        word = ''
        set.words.each do |w|
          word = w if input.scan(/\s#{w}\s/).present?
        end
        response = response.sub('*',word)
      end

    end
  end

end