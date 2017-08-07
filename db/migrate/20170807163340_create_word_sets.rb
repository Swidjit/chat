class CreateWordSets < ActiveRecord::Migration[5.0]
  def change
    create_table :word_sets do |t|
      t.string :keyword
      t.text :words
    end
  end
end
