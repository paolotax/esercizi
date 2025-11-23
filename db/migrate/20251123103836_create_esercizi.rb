class CreateEsercizi < ActiveRecord::Migration[8.1]
  def change
    create_table :esercizi do |t|
      t.string :title, null: false
      t.text :description
      t.string :slug, null: false
      t.string :category
      t.text :tags, default: '[]' # JSON serializzato per SQLite
      t.string :difficulty
      t.text :content, default: '{}' # JSON serializzato per SQLite
      t.datetime :published_at
      t.integer :views_count, default: 0
      t.string :share_token
      # t.references :user, foreign_key: true # Decommentare se hai un sistema di utenti

      t.timestamps
    end

    add_index :esercizi, :slug, unique: true
    add_index :esercizi, :share_token, unique: true
    add_index :esercizi, :category
    # Rimosso gin index perché non supportato da SQLite
    add_index :esercizi, :published_at
  end
end
