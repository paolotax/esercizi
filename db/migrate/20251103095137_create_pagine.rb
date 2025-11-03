class CreatePagine < ActiveRecord::Migration[8.1]
  def change
    create_table :pagine do |t|
      t.references :disciplina, null: false, foreign_key: true
      t.integer :numero, null: false
      t.string :titolo
      t.string :slug, null: false
      t.string :view_template
      t.integer :posizione, default: 0

      t.timestamps
    end
    add_index :pagine, :slug, unique: true
  end
end
