class CreateQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :questions do |t|
      t.references :esercizio, null: false, foreign_key: true
      t.references :account, foreign_key: true
      t.references :creator, foreign_key: { to_table: :users }
      t.string :questionable_type, null: false
      t.integer :questionable_id, null: false
      t.integer :position, default: 0
      t.integer :difficulty
      t.integer :points
      t.integer :time_limit

      t.timestamps
    end

    add_index :questions, [ :questionable_type, :questionable_id ]
    add_index :questions, [ :esercizio_id, :position ]
  end
end
