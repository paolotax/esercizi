class CreateSearchRecords < ActiveRecord::Migration[8.1]
  def up
    # Tabella normale per i dati
    create_table :search_records do |t|
      t.references :searchable, null: false, polymorphic: true
      t.references :pagina, foreign_key: true
      t.references :disciplina, foreign_key: true
      t.references :volume, foreign_key: true
      t.string :title
      t.text :content
      t.timestamps
    end

    add_index :search_records, [ :searchable_type, :searchable_id ], unique: true

    # Tabella virtuale FTS5
    execute <<-SQL
      CREATE VIRTUAL TABLE search_records_fts USING fts5(
        title,
        content,
        tokenize='porter'
      )
    SQL
  end

  def down
    execute "DROP TABLE IF EXISTS search_records_fts"
    drop_table :search_records, if_exists: true
  end
end
