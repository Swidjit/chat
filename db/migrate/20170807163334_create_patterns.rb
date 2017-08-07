class CreatePatterns < ActiveRecord::Migration[5.0]
  def change
    create_table :patterns do |t|
      t.belongs_to :intent
      t.string :pattern
      t.string :regexp
      t.timestamps
    end
  end
end
