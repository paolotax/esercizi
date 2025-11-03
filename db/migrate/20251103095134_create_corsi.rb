class CreateCorsi < ActiveRecord::Migration[8.1]
  def change
    create_table :corsi do |t|
      t.string :nome, null: false
      t.string :codice, null: false
      t.text :descrizione

      t.timestamps
    end
    add_index :corsi, :codice, unique: true
  end
end
