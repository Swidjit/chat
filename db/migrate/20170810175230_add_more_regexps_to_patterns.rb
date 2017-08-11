class AddMoreRegexpsToPatterns < ActiveRecord::Migration[5.0]
  def change
    add_column :patterns, :r1, :string
    add_column :patterns, :r2, :string
    add_column :patterns, :r3, :string
    add_column :patterns, :r4, :string
  end
end
