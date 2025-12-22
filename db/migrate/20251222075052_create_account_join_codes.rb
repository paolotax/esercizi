class CreateAccountJoinCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :account_join_codes do |t|
      t.references :account, null: false, foreign_key: true
      t.string :code, null: false
      t.string :role, null: false, default: "student"
      t.integer :usage_count, null: false, default: 0
      t.integer :usage_limit, null: false, default: 100

      t.timestamps
    end

    add_index :account_join_codes, :code, unique: true
  end
end
