class AddFieldsToSubstitutions < ActiveRecord::Migration[5.0]
  def change
    add_column :substitutions, :word, :string
    add_column :substitutions, :synonyms, :text, :array=>:true

  end
end
