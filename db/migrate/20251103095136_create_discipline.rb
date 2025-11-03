class CreateDiscipline < ActiveRecord::Migration[8.1]
  def change
    create_table :discipline do |t|
      t.references :volume, null: false, foreign_key: true
      t.string :nome, null: false
      t.string :codice, null: false
      t.string :colore

      t.timestamps
    end
  end
end
