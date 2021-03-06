namespace :init do
  task :seed => :environment do
    WordSet.delete_all
    WordSet.create(:keyword=>'i', :words => ['he', 'she', 'they', 'you', 'u', 'nobody', 'anybody', 'everyone', 'everybody', 'anyone'])
    WordSet.create(:keyword=>'you', :words => ['me','him','her','them','u', 'nobody', 'anybody', 'everybody', 'everyone', 'anyone'])
    WordSet.create(:keyword=>'your', :words => ['my','his','her','their','our'])
    WordSet.create(:keyword=>'yours', :words => ['mine','yours','his','her','theirs','ours'])


    WordSet.create(:keyword=>'ejaculate', :words => ['finish*','come','came','coming','climax*','explod*','releas*','complet*'])
    WordSet.create(:keyword=>'injure', :words => ['get','got','jump','drop','deck','sit','sat','split*','slic*','mess*','step*','hurt*','pound*','smack*','slap*','squash*','squish*','smash*','nail*','tear*','tore','torn'])
    WordSet.create(:keyword=>'kill', :words => ['rid','end*','terminat*','extinguish*','wast*','zap*','finish*','off*'])
    WordSet.create(:keyword=>'die', :words => ['depart','breathless','offed','breath*'])
    WordSet.create(:keyword=>'fail', :words => ['flop'])
    WordSet.create(:keyword=>'size', :words => ['small*','big*','siz*','large*','long'])
    WordSet.create(:keyword=>'command', :words => ['tell*','told','say*','saying','order'])
    WordSet.create(:keyword=>'nice', :words => ['friend*','kind'])


    WordSet.create(:keyword=>'stupid', :words => ['dense','slow','dull','thick','basic'])
    WordSet.create(:keyword=>'lame', :words => ['bad','slow','dull','thick'])
    WordSet.create(:keyword=>'smart', :words => ['quick','sharp','intelligent','bright'])
    WordSet.create(:keyword=>'wanted', :words => ['cool','seen','appreciated','liked','loved'])
    WordSet.create(:keyword=>'touch', :words => ['press*','hold*','push*','tap*','pat*','feel*','felt','brush*','handl*','pok*'])
    WordSet.create(:keyword=>'push', :words => ['shov*','press*','driv*','knock*','forc*'])
    WordSet.create(:keyword=>'insert', :words => ['put*','plac*','push*','slid*','load*','fit*','pop*','stick*','stuck','install*'])
    WordSet.create(:keyword=>'screw', :words => ['sit','sat','sleep*','slept','lay','laid','bed','couple','nail','take','took','tear*','tore','torn'])
    WordSet.create(:keyword=>'grab', :words => ['pull*','clasp*','hold*','tak*','hook*','catch*','seiz*','grip*'])
    WordSet.create(:keyword=>'own', :words => ['control*','possess*','rul*'])
    WordSet.create(:keyword=>'desire', :words => ['want*','need*','wish*','hop*','lik*','prefer*','enjoy*'])
    WordSet.create(:keyword=>'pull', :words => ['drag*','rip*','strecth*'])
    WordSet.create(:keyword=>'break', :words => ['split*','tear*','tore','torn'])
    WordSet.create(:keyword=>'force', :words => ['driv*','push*','nail*','mak*','made'])
    WordSet.create(:keyword=>'attack', :words => ['jump','drop','deck'])

    Substitution.delete_all
    Substitution.create(:word=>'but',:synonyms=>['although'])
    Substitution.create(:word=>'hard',:synonyms=>['difficult'])
    Substitution.create(:word=>'easy',:synonyms=>['simple'])
    Substitution.create(:word=>'grass',:synonyms=>['lawn'])
    Substitution.create(:word=>'sorry',:synonyms=>['oops'])
    Substitution.create(:word=>'bottom',:synonyms=>['floor'])
    #Substitution.create(:word=>'did you',:synonyms=>['were you'])
    #Substitution.create(:word=>'do you',:synonyms=>['does anyone'])


    #Substitution.create(:word=>'stuck',:synonyms=>['trapped'])

  end

  task :import, [:data_set]  => :environment  do |t, args|
    if args.data_set == 'lightweight'
      files = ['lightweight.csv','abbreviations.csv']
    else
      files = ['nouns.csv','core.csv','adjectives.csv','verbs.csv','abbreviations.csv']
    end
    Phrase.delete_all

    files.each do |f|
      file = File.open(f)
      file.each do |line|
        line=line.gsub(/("|\s)/,'')
        line.split(',').each do |word|
          Phrase.create(:str=>word.downcase.gsub(/[^0-9a-z ]/i, '')) if word.length > 0
        end
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
