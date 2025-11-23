class CreateEsercizioTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :esercizio_templates do |t|
      t.string :name, null: false
      t.text :description
      t.string :category
      t.text :default_config, default: '{}' # JSON serializzato per SQLite
      t.integer :usage_count, default: 0

      t.timestamps
    end

    add_index :esercizio_templates, :name
    add_index :esercizio_templates, :category
  end
end
