class CreateEsercizioAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :esercizio_attempts do |t|
      t.references :esercizio, null: false, foreign_key: true
      t.string :student_identifier
      t.datetime :started_at
      t.datetime :completed_at
      t.text :results, default: '{}' # JSON serializzato per SQLite
      t.float :score
      t.integer :time_spent # in secondi

      t.timestamps
    end

    add_index :esercizio_attempts, :student_identifier
    add_index :esercizio_attempts, [:esercizio_id, :student_identifier]
  end
end
