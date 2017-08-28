class Phrase < ActiveRecord::Base


  def self.check_if_valid(input)
    str = ''
    is_valid = true
    time = Benchmark.measure do
      input.split(' ').each do |word|
        matched = true
        str.length > 0 ? str += ' ' + word : str = word
        if ['a','i','u'].include?(word[0]) && word.length == 1

        elsif Phrase.find_by_sql("select * from phrases where phrases.str like '#{word}'").count > 0

        elsif word.length >= 4 && word[-1] == 's' && Phrase.find_by_sql("select * from phrases where phrases.str like '#{word[0..-2]}'").count > 0

        elsif word.length >= 7 && word[-4..-1] == 'ment' && Phrase.find_by_sql("select * from phrases where phrases.str like '#{word[0..-5]}'").count > 0

        elsif word.length >= 5 && word[-2..-1] == 'ly' && Phrase.find_by_sql("select * from phrases where phrases.str like '#{word[0..-3]}'").count > 0

        elsif word.length >= 5 && word[-2..-1] == 'ed' && Phrase.find_by_sql("select * from phrases where phrases.str like '#{word[0..-3]}'").count > 0

        elsif word.length >= 6 && word[-3..-1] == 'ing' && Phrase.find_by_sql("select * from phrases where phrases.str like '#{word[0..-4]}' OR phrases.str like '#{word[0..-5]}'").count > 0

        elsif word.length >= 6 && word[-3..-1] == 'ing' && Phrase.find_by_sql("select * from phrases where phrases.str like '#{word[0..-4]}e' OR phrases.str like '#{word[0..-4]+word[-4]}'").count > 0

        elsif word.length >= 6 && word[-3..-1] == 'ing' && Phrase.find_by_sql("select * from phrases where phrases.str like '#{word[0..-4]+word[-4]}'").count > 0

        elsif word.length >= 7 && word[-4..-1] == 'ness' && Phrase.find_by_sql("select * from phrases where phrases.str like '#{word[0..-5]}'").count > 0

        elsif word.length >= 7 && word[-4..-1] == 'less' && Phrase.find_by_sql("select * from phrases where phrases.str like '#{word[0..-5]}'").count > 0

        elsif word.length >= 7 && word[-4..-1] == 'ship' && Phrase.find_by_sql("select * from phrases where phrases.str like '#{word[0..-5]}'").count > 0

        elsif word.length >= 7 && word[-4..-1] == 'like' && Phrase.find_by_sql("select * from phrases where phrases.str like '#{word[0..-5]}'").count > 0

        elsif word.length >= 7 && word[-4..-1] == 'ling' && Phrase.find_by_sql("select * from phrases where phrases.str like '#{word[0..-5]}'").count > 0

        elsif word.length >= 6 && word[-3..-1] == 'ess' && Phrase.find_by_sql("select * from phrases where phrases.str like '%#{word[0..-4]}'").count > 0

        elsif word.length >= 6 && word[-3..-1] == 'ish' && Phrase.find_by_sql("select * from phrases where phrases.str like '%#{word[0..-4]}'").count > 0

        elsif word.length >= 7 && word[-4..-1] == 'able' && (Phrase.find_by_sql("select * from phrases where phrases.str like '%#{word[0..-5]}'").count > 0 || Phrase.find_by_sql("select * from phrases where phrases.str like '%#{word[0..-5]}e'").count > 0)


        else
          matched = false
        end
        is_valid = false if !matched
      end
    end
    puts "time: #{time.real*1000}"
    return is_valid
  end

  def self.check_if_exact(input)
    p = Phrase.find_by_str(input.strip)
    puts input.strip
    puts 'lalal'
    if p.present?
      return 'exact'
    else
      return 'partial'
    end
  end

end
