class AddAccountToExistingModels < ActiveRecord::Migration[8.1]
  def change
    # Add account_id to all tenant-scoped models
    add_reference :corsi, :account, foreign_key: true
    add_reference :volumi, :account, foreign_key: true
    add_reference :discipline, :account, foreign_key: true
    add_reference :pagine, :account, foreign_key: true
    add_reference :esercizi, :account, foreign_key: true
    add_reference :esercizio_attempts, :account, foreign_key: true

    # Add user_id to EsercizioAttempt for authenticated attempts
    add_reference :esercizio_attempts, :user, foreign_key: true

    # Add creator association to esercizi
    add_reference :esercizi, :creator, foreign_key: { to_table: :users }

    # Create indexes for tenant queries
    add_index :corsi, [ :account_id, :created_at ]
    add_index :esercizi, [ :account_id, :created_at ]
    add_index :esercizio_attempts, [ :account_id, :user_id ]
  end
end
