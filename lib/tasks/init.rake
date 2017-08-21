namespace :init do
  task :seed => :environment do
    WordSet.delete_all
    WordSet.create(:keyword=>'pronoun', :words => ['me','you','him','her','them'])

  end

  task :import => :environment do
    Phrase.delete_all
    files = ['nouns.csv','core.csv','adjectives.csv','verbs.csv','abbreviations.csv']
    files.each do |f|
      file = File.open(f)
      file.each do |line|
        Phrase.create(:str=>line.downcase.gsub(/[^0-9a-z ]/i, '')) if line.length > 0
      end
    end

    Blacklist.delete_all
    files = ['blacklist.csv']
    files.each do |f|
      file = File.open(f)
      file.each do |line|
        parts = line.split(',')
        if line.length > 0
          parts.length > 1 ? (Blacklist.create(:pattern=>parts[0].downcase, :mode=>'pattern')) : (Blacklist.create(:pattern=>parts[0].downcase, :mode=>'word'))
        end
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
      puts s
      s = s[7..-8]
      puts s
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