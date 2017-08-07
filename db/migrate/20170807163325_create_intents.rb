class CreateIntents < ActiveRecord::Migration[5.0]
  def change
    create_table :intents do |t|
      t.string :name
      t.string :response
      t.string :pattern
      t.belongs_to :grouping
    end
  end
end
