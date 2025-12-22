class CreateClassi < ActiveRecord::Migration[8.1]
  def change
    create_table :classi do |t|
      t.references :account, null: false, foreign_key: true
      t.references :teacher, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.string :anno_scolastico

      t.timestamps
    end

    add_index :classi, [:account_id, :name, :anno_scolastico], unique: true
  end
end
