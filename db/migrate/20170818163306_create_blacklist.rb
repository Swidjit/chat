class CreateBlacklist < ActiveRecord::Migration[5.0]
  def change
    create_table :blacklists do |t|
      t.string :pattern
      t.string :regexp
      t.string :mode
    end
  end
end
