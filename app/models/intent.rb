class Intent < ActiveRecord::Base
  has_many :patterns

  after_create :make_pattern

  def make_pattern
    p = Pattern.create(:pattern=>self.pattern, :intent_id => self.id)
  end

  def self.ask(input)
    pattern = Pattern.new
    response = ''
    matched=false
    reversed = false
    intent = Intent.new
    time = Benchmark.measure do
      #remove all non alphanumeric characters
      input = input.gsub(/[^a-z0-9\s]/i, '')
      puts input
      match_count = []
      records = Pattern.where("pattern = ?",input)
      if records.present?
        match_count << records.first.id
        matched = true
      end

      words = input.split(' ')

      unless matched
        words.each do |word|
          records = Pattern.find_by_sql("select * from patterns where patterns.regexp like '%"+word+"%'")
          records.each do |p|
            puts p.regexp
            result= Regexp.new(p.regexp) =~ input
            if(result==0)
              match_count << p.id
              matched = true
            end
          end

        end
      end
      unless matched
        words.each do |word|
          records = Pattern.find_by_sql("select * from patterns where patterns.regexp like '%"+word+"%'")
          records.each do |p|
            result= Regexp.new(p.regexp) =~ input
            if(result==0)
              match_count << p.id
              matched = true
            end
          end
        end
      end

      #now try again by removing endings
      unless matched
        words.each do |word|
          word = word[0..-4] if word[-3..-1] == 'ing'
          word = word[0..-3] if word[-2..-1] == 'ed'
          word = word[0..-2] if word[-1] == 's'
          word = word[0..-5] if word[-4..-1] == 'ment'
          word = word[0..-4] if word[-3..-1] == 'ion'
          records = Pattern.find_by_sql("select * from patterns where patterns.regexp like '%"+word+"%'")
          records.each do |p|
            result= Regexp.new(p.regexp) =~ input
            if(result==0)
              match_count << p.id
              matched = true
            end
          end
        end
      end

      #now try again with sentence inverted
      unless matched
        reversed = true
        tmp = input.split(' ')
        tmp = tmp.reverse
        reverse_input = tmp.join(' ')
        words.each do |word|
          word = word[0..-4] if word[-3..-1] == 'ing'
          word = word[0..-3] if word[-2..-1] == 'ed'
          word = word[0..-2] if word[-1] == 's'
          word = word[0..-5] if word[-4..-1] == 'ment'
          word = word[0..-4] if word[-3..-1] == 'ion'
          records = Pattern.find_by_sql("select * from patterns where patterns.regexp like '%"+word+"%'")
          records.each do |p|
            result= Regexp.new(p.regexp) =~ reverse_input
            if(result==0)
              match_count << p.id
              matched = true
            end
          end
        end
      end

      if matched
        #check if there are multiple matches with same count, which is better?
        @counts = match_count.each_with_object(Hash.new(0)){ |m,h| h[m] += 1}.sort_by {|k,v| v}
        val=0
        best_match = 0
        max_points=0
        @counts.each do |match,count|

          if best_match == 0
            val = count
            best_match = match
          end

          if count < val
            break
          else

            #check the match value of tied matches
            pattern = Pattern.find(match)

            points=0
            pattern.pattern.split(' ').each do |ch|

              unless ch == '*' || ch == '^'

                if ch.include? '/'
                  points = points + 2
                elsif ch.include? '['
                  points = points + 2
                elsif ch.length >= 6
                  points = points+2
                elsif ch.length >= 5
                  points = points+1
                elsif ch.length >=4
                  points = points+ 0.5
                end

              end
              if points > max_points
                best_match = match
                max_points=points
              end
            end
          end
        end

        #load the best pattern match
        pattern = Pattern.find(best_match)
        intent = pattern.intent

      end

    end

    return {:response => intent.response, :success => matched}

  end



end
