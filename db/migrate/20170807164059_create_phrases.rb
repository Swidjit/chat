class CreatePhrases < ActiveRecord::Migration[5.0]
  def change
    create_table :phrases do |t|
      t.string :str
      t.string :pattern
      t.integer :age
      t.integer :game_id
    end
  end
end
