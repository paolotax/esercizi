class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.references :account, null: false, foreign_key: true
      t.references :identity, foreign_key: true
      t.string :name, null: false
      t.string :role, null: false, default: "student"
      t.boolean :active, null: false, default: true
      t.datetime :verified_at

      t.timestamps
    end

    add_index :users, [:account_id, :identity_id], unique: true
    add_index :users, :role
  end
end
