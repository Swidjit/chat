class Phrase < ActiveRecord::Base


  def self.check_if_valid(input)
    str = ''
    is_valid = true
    input.split(' ').each do |word|
      matched = true
      str.length > 0 ? str += ' ' + word : str = word
      phrase = Phrase.where('str LIKE ?', "%#{str}%").first
      if phrase.present?

      else
        matched = false
      end

      if !matched
        matched = true
        phrase = Phrase.where('str LIKE ?', "%#{word}%").first
        if phrase.present?

        else
          matched = false
        end
      end

      is_valid = false if !matched
    end
    return is_valid
  end

  def self.check_if_exact(input)
    p = Phrase.find_by_str(input.strip)
    puts input.strip
    if p.present?
      return 'exact'
    else
      return 'partial'
    end
  end

end
