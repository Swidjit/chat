namespace :experiments do
  task :substitutions => :environment do
    files = ['contractions.csv']
    subs = {}
    files.each do |f|
      file = File.open(f)
      file.each do |line|
        parts = line.split(',')
        puts parts[0]
        puts parts[1].split('/')[0].strip
        subs[parts[0]] = parts[1].split('/')[0].strip
      end
    end
    puts subs
  end

  task :regex => :environment do

    p = '(polish* [object-pronoun] off)|(rub* [object-pronoun] off)'

    chunks = p.split(' ')
    chunks.each do |ch|
      #look for set syntax ... and make sure there is no space in the match or else it could be two sets eg 'do you [like] [sports]'
      #may need to change if we want to allow sets names with more than one word
      #match a range of words ^(?:\w+\s){0,3}(?:\w+)$
      result= Regexp.new(/\[((?!\s|\/).)*\]/) =~ ch
      if(result==0)
        set = WordSet.find_by_keyword(ch[1..-2])
        str = '(' + set.words.join('|') + ')'
        p = p.gsub(ch,str)
      elsif(result)
        sets = ch.gsub(/(\(|\))/,'').split('|')
        puts sets
        sets.each do |s|

          check= Regexp.new(/\[((?!\s|\/).)*\]/) =~ s
          if check==0
            puts s[1..-2]            
            set = WordSet.find_by_keyword(s[1..-2])
            str = '(' + set.words.join('|') + ')'
            p = p.gsub(s,str)
          end
        end
      end
    end
    #allow for optional words, eg 'this ?strange thing -> 'this thing' or 'this strange thing' but not 'this odd thing'
    matches = p.scan(/\s\?\w+\s/)
    matches.each do |n|
      p = p.gsub(n,"(\\s#{n[2..-2]})? ")
    end
    #allow for wildcard endings eg 'scien*' -> 'science','scientist','scientific'
    p = p.gsub(/\*\s/,'(\w+)?\s')
    #allow for infinite words betwen patterns, eg 'put ^ away ^' -> 'put away' or 'put that ridiculous thing away right now'
    p = p.gsub(/(\s)?\^(\s)?/,'\s.{0,}')
    #allow for finite number of words to appear between patterns, eg 'I {1} put' -> 'I put' or 'I last put', but not 'I most recently put'
    p = p.gsub(/\?\{\d\}\s/,"")
    matches = p.scan(/\{\d\}/)
    matches.each do |n|
      p = p.gsub(n,"(?:\\w+\\s){0,#{n[1]}}(?:\\w+)")
    end

    puts p
  end
end
