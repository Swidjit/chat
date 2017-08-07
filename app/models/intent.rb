class Intent < ActiveRecord::Base
  has_many :patterns

  after_create :make_pattern

  def make_pattern
    p = Pattern.create(:pattern=>self.pattern, :intent_id => self.id)
    puts self.inspect
  end

end
